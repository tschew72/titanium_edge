   $.fn.editable.defaults.mode = 'inline';


    tinymce.init({
            selector: "textarea",

        toolbar1: "newdocument fullpage | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect formatselect fontselect fontsizeselect",
        toolbar2: "cut copy paste | searchreplace | bullist numlist | outdent indent blockquote | undo redo | link unlink anchor image media code | insertdatetime preview | forecolor backcolor",
        toolbar3: "table | hr removeformat | subscript superscript | charmap emoticons | print fullscreen | ltr rtl | spellchecker | visualchars visualblocks nonbreaking template pagebreak restoredraft",

            menubar: false,
            toolbar_items_size: 'small',

    });

    tinymce.init({
            selector: ".editables1", 
            inline: true, 
        toolbar1: "newdocument fullpage | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect formatselect fontselect fontsizeselect",
        toolbar2: "cut copy paste | searchreplace | bullist numlist | outdent indent blockquote | undo redo | link unlink anchor image media code | insertdatetime preview | forecolor backcolor",
        toolbar3: "table | hr removeformat | subscript superscript | charmap emoticons | print fullscreen | ltr rtl | spellchecker | visualchars visualblocks nonbreaking template pagebreak restoredraft",
            menubar: false,
            toolbar_items_size: 'small',


    });

    tinymce.init({
            selector: ".editables2",
            inline: true, 
        toolbar1: "newdocument fullpage | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect formatselect fontselect fontsizeselect",
        toolbar2: "cut copy paste | searchreplace | bullist numlist | outdent indent blockquote | undo redo | link unlink anchor image media code | insertdatetime preview | forecolor backcolor",
        toolbar3: "table | hr removeformat | subscript superscript | charmap emoticons | print fullscreen | ltr rtl | spellchecker | visualchars visualblocks nonbreaking template pagebreak restoredraft",
            menubar: false,
            toolbar_items_size: 'small',

    });

   $(document).ready(function() {
      
      $('#firstname').editable();
      $('#age').editable();
      $('#gender').editable({   
        source: [
          {value: "M", text: 'Male'},
          {value: "F", text: 'Female'},
        ]
      });

      $('#profiletable').dataTable( {
          "bsort": false,
          "scrollCollapse": true,
          "jQueryUI": true,
      } );


   } );
/*
function clickButton()
  {
    document.getElementByID('ss').click()

  }

function alertMsg()
  {
    alert ("Button I was clicked!")
  }
*/


// $(document).on('submit','ss',function (e) {
//     e.preventDefault();
//     var ed = tinyMCE.get('responsibilities');
//     var data = ed.getContent();
//     var id = $('#id').val();

//     console.log(id);
//     $.ajax({
//         type:       'GET',
//         cache:      false,
//         url:        '/jobupdate',
//         data:       'id=' + id +'&responsibilities=' + escape(data),
//         success:    function(){
//                     $("#ss").remove();
//                     $("#output").html(data);
//         }
//     });
//     return false;
// });
