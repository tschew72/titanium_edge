var viewMoreButtons = document.querySelectorAll('.more');

var toggleVisibile = function(el) {
  if (el.style.fontSize === '0px' || el.style.fontSize === '')
     el.style.fontSize = '1.5rem';

  else
     el.style.fontSize = '0px';
};

var toggleText = function(el) {
  if (el.innerHTML === 'View Details')
    el.innerHTML = 'View Less';
  else 
    el.innerHTML = 'View Details';
};

var viewMoreButtonClickHandler = function(currBtn) {
  var details = currBtn.nextSibling;
  while(details.nodeType !== 1) details = details.nextSibling;  //try $('li.current_sub').prevAll("li.par_cat:first");
  toggleVisibile(details);                                          //http://stackoverflow.com/questions/2310270/jquery-find-closest-previous-sibling-with-class
  toggleText(currBtn);
};


// var viewMoreButtonClickHandler = function(currBtn) {
//   var details=$(currBtn).nextAll("div.details:first");
//   #document.write (details);
//   toggleVisibile(details);                                          
//   toggleText(currBtn);
// };

var moveDown = function(btnToMove) {
  
};

var addEventListenerPlus = function(i) {
  viewMoreButtons.item(i).addEventListener('click', 
    function(e) {
      var nextI;
      viewMoreButtonClickHandler(this);
      if (i%2 !== 0 && (i + 2) < viewMoreButtons.length) {
        moveDown(viewMoreButtons.item(i+2));
      }
    }, false);
};

for(var i=0; i < viewMoreButtons.length; i++) {
  addEventListenerPlus(i);
}