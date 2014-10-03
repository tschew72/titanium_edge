
     $("#revealcheck").on('change', function(){
          $.ajax({
            url: '/updaterevealcoy',
            type: 'POST',
            data: {"job_companyreveal": this.checked, "pk" : <%=@job.id %>}
          });
      });


       $('#job_contactname').editable(
    {
      emptytext: '--',
    // placeholder: '[Optional] Enter your achievement here'
  });