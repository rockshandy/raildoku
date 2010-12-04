// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// need to get rails3 working with jquery, I remember some alternatve file you can get
// since default is silly prototype
$(function() {
    drawBlockBorders($('#board'));

    $('#init').click(function(){
        // may need to get forms.js plugin
        // basically taking all input and siabling anything filled in
        // I think there is a way to only select fields with a value
        $('#board input').each(function() {
            if( this.value!=='' ) {
                if ( validMove($('board table'),$(this)) ) {
                    // any value that is filled in is made perminent
                    $(this).attr('disabled','disabled')
                } else {
                    // shade in error
                    $(this).addClass('error')
                }
            }
        })

        $('#start').hide();
        $('#help').show();
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

    $('#res').click(function() {
       // clear anything that had an error
       $('input.error').removeClass();
       $('input:disabled').removeAttr('disabled');
       // TODO: how to change the table dimensions! oh could look at value of width probably?
       $('#start').show();
       $('#help').hide();
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
    var valid = false;
    var max = maxVal();
    // need to know how to ensure we have a number...
    // also need to strip the val() of whitespace
    if ( $pos.val() > 0 && $pos.val() <= maxVal() ) valid = true

    return valid
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

    $board.find('tr:nth-child(' + height + 'n+1)').addClass('grid');
    $board.find('tr td:nth-child(' + width + 'n+1)').addClass('grid');
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

