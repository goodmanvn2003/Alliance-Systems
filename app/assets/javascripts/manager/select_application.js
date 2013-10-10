$(function(){

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $("#appSelect").on("change", function(){
        var value = $(this).val();

        $.getJSON("/manager/r/services/list/" + value, function(response){
            if (response.status == "success")
            {
                //var html = "<option value=\"\" selected=\"selected\">select a role</option>";
                var html = "";

                for (var i = 0; i < response.data.length; i++)
                {
                    html += "<option value=\"" +response.data[i].id + "\">" + response.data[i].name.trim() + "</option>"
                }

                $("#roleSelect").html(html);
            } else
            {
                Messenger().post("unable to get roles for user of this site");
            }
        }).error(function(){
            Messenger().post("unable to contact server");
        });
    });

    $("#siteRegistration").on("shown", function(){
        $("#siteModalName").val("");
        $("#siteModalDescription").val("");
        $("#siteModalCreateBtn").text("create");
        $("#siteModalCreateBtn").removeAttr("disabled");
        $("#siteModalCancelBtn").removeAttr("disabled");
    });

    $("#siteModalCreateBtn").on("click", function(){
        if ($("#siteModalName").val().trim().length > 6)
        {
            $("#siteModalCreateBtn").attr("disabled","disabled");
            $("#siteModalCancelBtn").attr("disabled","disabled");
            $("#siteModalCreateBtn").text("creating...");

            $.post("/manager/site/services/create",
                {
                    "name" : $("#siteModalName").val(),
                    "description" : $("#siteModalDescription").val()
                }, function(response){
                    if (response.status == "success")
                    {
                        $("#siteModalCreateBtn").text("create");
                        Messenger().post("Site is successfully created");
                        location.reload();
                    }
                    else
                    {
                        $("#siteModalCreateBtn").text("create");
                        $("#siteModalCreateBtn").removeAttr("disabled");
                        $("#siteModalCancelBtn").removeAttr("disabled");
                        Messenger().post("unable to create new site");
                    }
                }).error(function(){
                    $("#siteModalCreateBtn").text("create");
                    $("#siteModalCreateBtn").removeAttr("disabled");
                    $("#siteModalCancelBtn").removeAttr("disabled");
                    Messenger().post("unable to contact server");
                });
        }
        else
        {
            Messenger().post("Name is too short or empty");
        }
    });

});
