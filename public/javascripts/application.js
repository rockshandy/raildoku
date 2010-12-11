// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// need to get rails3 working with jquery, I remember some alternatve file you can get
// since default is silly prototype
$(function() {
    drawBlockBorders($('#board'));

    $('#init').click(function(){
        failed = false;
        // may need to get forms.js plugin
        // basically taking all input and disabling anything filled in
        // I think there is a way to only select fields with a value
        $('input.error').removeClass();
        $('#board input').each(function() {
            if( this.value!=='' ) {
                if ( validMove($('board table'),$(this)) ) {
                    // any value that is filled in is made perminent
                    $(this).attr('disabled','disabled')
                } else {
                    // shade in error
                    $(this).addClass('error')
                    failed = true
                }
            }
        })

        if (failed) {return false};

        $('#start').hide();
        $('#help').show();
        // ensure when submit triggers it's the right action'
        $('form').attr('action','init')
    });

    //need to fiure out how to change this whenever changes or clicked if that's possible?
    // like as soon as you with change the number if it regresses to text or on click if it's on an arrow?'
    $('#dimensions input').change(function(e) {
        var $board = $('#board')
        // remove block borders
        removeBlockBorders($board);

        // adjust the board as needed
        modBoard($board);

        //redraw borders
        drawBlockBorders($board);
    });

    $('#board input').live('change',function(e) {
        // check some constraints
        if ($(this).val() == '') return

        if (!validMove($('#board'),$(this))) {
            $(this).addClass('error').attr('data')
        } else {
            // in case correctly a previous errored cell
            $(this).removeClass('error')
        }
    })

    $('input.error').live('mouseenter mouseleave', function(event) {
        if (event.type == 'mouseenter') {
            // display error message
            $(this).after('<aside class="errBox">'
                 + $(this).attr('data-msg')
                 + '</aside>')
        } else {
            // hide it
            $('aside.errBox').remove()
        }
    });

    $('#solve').click(function() {
        $('form').attr('action','solve')
    });

    $('#res').click(function() {
       // clear values
       $('#board input').each(function(){
           $(this).val('')
       });

       // clear extra
       reset_board();
    });

    $('form').submit(function(){
        data = ''
        // convert all inputs to a comma seperated list
        $('#board td input').each(function(){
            data += ($(this).val() || '0') + ','
        });
        $('form #board_value').val(data)
    })
    // consider splitting up for init and reset but group for now
    $('form[data-remote]').bind("ajax:success", function(e, data, status, xhr) {
        var flash = ''
        if (data instanceof Object) {
            $.each(data, function(key,val) {
                flash += key + ':' + val + '\n'
            });
            reset_board();
            alert(flash);
        } else if (data.length > 1){
            // data holds the solved board
            sol = data.split(',')
            $(this).find('#board input').each(function(i) {
                $(this).val(sol[i])
            });
        };
    });
});

/*@brief validate a position on the sudoku board
 *
 *  @param $board   jQuery object representing a board
 *  @param $pos     jQuery object representing position on board to check
 *
 *  @return boolean representing validaty
 *
 *  might be able to make faster with some jquery tricks or just assigning
 *  classes to everything intially once size is acquired
 */
function validMove ($board,$pos) {
    var stillValid = true
    var notChecking = ':not(input[data-checking])'
    var posVal = $pos.val()
    var $td = $pos.closest('td')
    var msg = null

    // add data-checking to figure out which cell this is
    // which will simplify selecting by using :not(input[data-checking])
    // and first remove anything that was checked last round
    $board.find('input[data-checking]').removeAttr('data-checking')
    $pos.attr('data-checking','true')

    // need to know how to ensure we have a number...
    // also need to strip the val() of whitespace
    // TODO: make this || group quicker
    if ( posVal <= 0 || posVal > maxVal() || !+posVal ) {
        stillValid = false
        msg = 'Value should be within 1 and ' + maxVal()
    } else {
        // check row
        $td.siblings().each(function(){
            if (posVal == $(this).find('input').val()) {
                stillValid = false
                msg = 'Oh noes, there is a dublicate in this row!'
                return false
            }
        });

        if (stillValid) {
            // check column
            $('tr td:nth-child('
                + ($td.prevAll().length + 1)
                + ') input'+notChecking)
                .each(function(){
                    if (posVal == $(this).val() ) {
                        msg = 'Aww snap,there is dublicate in this column'
                        stillValid = false
                        return false
                    }
                })

            if (stillValid) {
                // check block
                $('input[data-blk="' + $pos.attr('data-blk') + '"]' + notChecking)
                    .each(function(){
                        if (posVal == $(this).val() ) {
                            stillValid = false
                            msg = 'Drat, there is a dublicate value in this block!'
                            return false
                        }
                    });
            }
        }
    }

    if (stillValid){
        // apply message to position so hovering reveals what happened
        $pos.removeAttr('data-msg')
    } else {
        $pos.attr('data-msg',msg)
    }
    return stillValid
}
function removeBlockBorders($board) {
    var height = Math.sqrt($board.find('tr').length);
    var width = Math.sqrt($board.find('tr:first td').length);

    $board.find('tr:nth-child(' + height + 'n+1)').removeAttr('class');
    $board.find('tr td:nth-child(' + width + 'n+1)').removeAttr('class');
}
/*@brief can be used to draw block borders on #board
 *
 *  will be more general purpose later where you can use it like any jquery function
 */
 //TODO: way to do this with straight css? perhaps look at nth or eq filters

function drawBlockBorders($board) {
    var height = $('#height').val();
    var width = $('#width').val();

    // add block grid
    $board.find('tr:nth-child(' + height + 'n+1)').addClass('grid');
    $board.find('tr td:nth-child(' + width + 'n+1)').addClass('grid');

    // add block numbers in data-blk attr
    $board.find('tr').each(function(j){
        $(this).find('input').each(function(i){
            $(this).attr('data-blk',Math.floor(i/height) + width * Math.floor(j/width))
        });
    });
}

function maxVal() {
    return $('#width').val() * $('#height').val()
}

/*@brief add or remove from board to match height and width values
 *
 *  @param $board   jquery object of board (a table)
 *  @param dim      object with propperties w for width and h for height
 */
function modBoard($board) {
    var textToInsert = '';
    var max = maxVal();
    var dim = {w: $board.find('tr:first td').length,
               h: $board.find('tr').length }

    // TODO: look at various js string multiplication methods
    if (dim.w < max){
        var cloneHtml = '<td>' + $board.find('td:first').html()  + '</td>';
        // add appropiate num of columns
        // TODO:could need form to reset all the form values to blank but not big deal now
        for(i=dim.w;i<max;i++) {
            textToInsert += cloneHtml
        }
        $board.find('tr').append(textToInsert);
        textToInsert = '';
    } else {
        //remove any un-needed columns
        $board.find('tr').each(function(){
            $(this).find('td:gt(' + (max - 1) + ')').remove();
        });
    }

    if (dim.h < max){
        cloneHtml = '<tr>' + $board.find('tr:first').html() + '</tr>';
        // add appropiate num of rows
        for(i=dim.h;i<max;i++) {
            textToInsert += cloneHtml
        }
        $board.append(textToInsert);
    } else {
        // remove any un-needed rows
        $board.find('tr:gt(' + (max - 1) + ')').remove();
    }
}

// the stuff that happens when a board reset without the values being reset
// mostly for what happens on error from the server that you'd want to keep
// the values already in the board for
function reset_board(){
    $('input.error').removeClass();
    $('input:disabled').removeAttr('disabled');
    // TODO: how to change the table dimensions! oh could look at value of width probably?
    $('#start').show();
    $('#help').hide();
    return false
}

