
  $('#job_contactname').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
  });


    $('#job_contactemail').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
  });

      $('#job_contactphone').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
  });


     // $("#revealcheck").on('change', function(){
     //      $.ajax({
     //        url: '/updaterevealcoy',
     //        type: 'POST',
     //        data: {"job_companyreveal": this.checked, "pk" : <%=@myjob.id %>} //need to change 1 to dynamic!!! TSCHEW
     //      });
     //  });


      function revealcheck(i){

      		 $.ajax({
	            url: '/updaterevealcoy',
	            type: 'POST',
	            data: {"job_companyreveal": this.checked, "pk" : i} //need to change 1 to dynamic!!! TSCHEW
	          });

       	

      }//function