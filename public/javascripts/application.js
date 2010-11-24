// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// need to get rails3 working with jquery, I remember some alternatve file you can get
// since default is silly prototype
$(function() {
    drawBlockBorders();

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
    });

    //need to fiure out how to change this whenever changes or clicked if that's possible?
    // like as soon as you with change the number if it regresses to text or on click if it's on an arrow?'
    $('#dimensions input').change(function(e) {
        //TODO: can probably reduce the uses of creating a new jquery object and just filter down? and max()
        var newDim = { w: $('#width').val(),
                       h: $('#height').val() }
        var oldDim = { w: $('#board tr:first td').length,
                       h: $('#board tr').length }
        var textToInsert = '';
        // TODO:could need form to reset all the form values to blank but not big deal now
        var $tdClone = $('#board td:first');
        // TODO: look at various js string multiplication methods
        // add appropiate num of columns
        for(i=oldDim.w;i<maxVal();i++) {
            textToInsert += '<td>' + $tdClone.html() + '</td>'
        }
        $('#board tr').append(textToInsert);
        textToInsert = '';
        var $trClone = $('#board tr:first');

        // add appropiate num of rows
        for(i=oldDim.h;i<maxVal();i++) {
            textToInsert += '<tr>' + $trClone.html() + '</tr>'
        }

        $('#board table').append(textToInsert);
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

/*@brief can be used to draw block borders on #board
 *
 *  will be more general purpose later where you can use it like any jquery function
 */
function drawBlockBorders() {
    var $board = $('#board');
    var height = $('#height').val();
    var width = $('#width').val();

    //NOTE: consider removing td/tr borders or how to start fresh

    // no idea how to do this right now but needed to make easier to see blocks
    // could maybe do it in rails if this was an ajax call
    // or maybe add the position of a td to it's class? just seems messy
    $board.find('tr').each(function(i){
        if (i % height === 0) $(this).addClass('grid');

        $(this).children('td').each(function(i){
            if (i % height === 0) $(this).addClass('grid')
        })
    })
}

function maxVal() {
    return $('#width').val() * $('#height').val()
}

