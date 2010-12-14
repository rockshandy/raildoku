// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// need to get rails3 working with jquery, I remember some alternatve file you can get
// since default is silly prototype
$(function() {
    drawBlockBorders($('#board'));

    $('#init').click(function(){
        var failed = false;
        var $matched = $();
        // basically taking all input and disabling anything filled in
        // TODO: there might be a way to only select fields with a value
        $('input.error').removeClass();
        $('#board input').each(function() {
            if( this.value!=='' ) {
                if ( validMove($('#board'),$(this)) ) {
                    // any value that is filled in is made perminent if no failures
                    $matched = $matched.add(this)
                } else {
                    // shade in error
                    $(this).addClass('error')
                    failed = true
                }
            }
        })

        if (failed) {
            return false
        } else {
            $matched.attr('disabled','disabled')
        };

        $('.start').hide();
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
        // this should only work begore initialization
        if ($('#init:visible').length == 0) return

        // check some constraints
        if ($(this).val() == '') return

        if (!validMove($('#board'),$(this))) {
            $(this).addClass('error').attr('data')
        } else {
            // in case correctly a previous errored cell
            $(this).removeClass('error')
        }
    })
    // FIXME: this box is not displaying where it should
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

    // for now picks a random spot from funning constaints on the board
    //TODO: add common code to a function you can call maybe?
    // OPTIMIZE: make everything dry!
    $('#hint').click(function(){
        // first need to make sure the board has been checked
        $('#check').click()
        if ($('input.error').length > 0) return false

        data = {
            value: getBoardValues($('#board')),
            width: $('#width').val(),
            height: $('#height').val()
        }

        $.getJSON('hint',data, function(data, textStatus, xhr) {
            var irand
            var closed = data[2]
            var open = data[1]
            var board = data[0]
            var i,j

            if (data===false) {
                alert('Oops the board is invalid, might want to roll back some steps')
                return false
            }

            // look through closed list and see if any values were set
            if (closed.length > 0) {
                irand = Math.floor(Math.random()*closed.length)
                // then fill in that square and hfilled class
                i = closed[irand][0]
                j = closed[irand][1]
                $('#board tr:nth-child(' + (i + 1) + ')'
                    + ' td:nth-child(' + (j + 1) + ')'
                    + ' input').val(board[i][j])
            } else {
                // have to use the open list and just hint at possible fill ins
                irand = Math.floor(Math.random()*open.length)
                // add hint values and message
                i = open[irand][0]
                j = open[irand][1]
                $('#board tr:nth-child(' + (i + 1) + ')'
                    + ' td:nth-child(' + (j + 1) + ')'
                    + ' input').attr('data-hint',board[i][j])
            }
        });
    });
    // FIXME: if unsolvable with aditional user input (after initialize) tell to first try and roll back further input
    //          since not doing background can't really solve intill that button is actually hit
    // TODO: make this live hover aspect cookie cutter function so hint or errors can use it
    // perhaps change the error class to simply a data-err attribute, which would change data-msg to that as well
    // then could have the names hintBox and errBox could just pass in 'hint' or 'err' to generate!
    $('input[data-hint]').live('mouseenter mouseleave', function(event) {
        if (event.type == 'mouseenter') {
            // display error message
            $(this).after('<aside class="hintBox">'
                 + $(this).attr('data-hint')
                 + '</aside>')
        } else {
            // hide it
            $('aside.hintBox').remove()
        }
    });

    // checks entire board for any invalid cells
    $('#check').click(function(){
        $('#board input:enabled').each(function() {
            if( this.value!=='' && !validMove($('#board'),$(this)) ) {
                $(this).addClass('error')
            } else {
                $(this).removeClass('error')
            }
        })
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
        data = getBoardValues($('#board'))
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
 *  classes to everything intially once size is acquired. Currently finds all
 *  errors with a cell, can pass in optional true to use StillValid and fail
 *  as soon as one error is found
 */
function validMove ($board,$pos,failFast) {
    var stillValid = true
    var notChecking = ':not(input[data-checking])'
    var posVal = $pos.val()
    var $td = $pos.closest('td')
    var msg = 'Oh noes, there is a dublicate in this'

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
                msg += ' row'
                return false
            }
        });

        if (stillValid || !failFast) {
            // check column
            $('tr td:nth-child('
                + ($td.prevAll().length + 1)
                + ') input'+notChecking)
                .each(function(){
                    if (posVal == $(this).val() ) {
                        msg += (stillValid ? ' column'
                                           : ' and column')
                        stillValid = false
                        return false
                    }
                })

            if (stillValid || !failFast) {
                // check block
                $('input[data-blk="' + $pos.attr('data-blk') + '"]' + notChecking)
                    .each(function(){
                        if (posVal == $(this).val() ) {
                             msg += (stillValid ? ' block'
                                                : ' and block')
                            stillValid = false
                            return false
                        }
                    });
            }
        }
    }

    if (stillValid){
        // remove any previous message
        $pos.removeAttr('data-msg')
    } else {
         // apply message to position so hovering reveals what happened
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
function drawBlockBorders($board) {
    var height = $('#height').val();
    var width = $('#width').val();

    // add block grid
    $board.find('tr:nth-child(' + height + 'n+1)').addClass('grid');
    $board.find('tr td:nth-child(' + width + 'n+1)').addClass('grid');

    // add block numbers in data-blk attr
    $board.find('tr').each(function(j){
        $(this).find('input').each(function(i){
            $(this).attr('data-blk',Math.floor(i/width) + height * Math.floor(j/height))
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
    $('.start').show();
    $('#help').hide();
    $('input[data-hint]').removeAttr('data-hint')
    return false
}

// get the values from the board for ajax requests
function getBoardValues ($board) {
    data = ''
    // convert all inputs to a comma seperated list
    $board.find('input').each(function(){
        data += ($(this).val() || '0') + ','
    });
    return data
}

