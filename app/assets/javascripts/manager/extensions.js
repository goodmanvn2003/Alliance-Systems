$(function(){

    var extension_url = $($($("#extensionsList li.active").first()).find("a:first")).attr("data-link");
    var extension_installer = $($($("#extensionsList li.active").first()).find("a:first")).attr("data-installer");

    if (extension_url != undefined && extension_url.length > 0)
    {
        $("#body").addClass("container");
        $("#body").css("text-align","center");
        $("#body").css("padding","45px 0 45px 0");
        $("#body").html("<h4>loading extension, please wait...</h4>");

        $.get(extension_url, function(response){
            $("#body").removeClass("container");
            $("#body").css("text-align","");
            $("#body").css("padding","");
            $("#body").html(response);
        }).error(function(){
            $("#body").html("<h4>loading extension's installer...</h4>");

            if (extension_installer != undefined && extension_installer.length > 0)
            {
                $.get(extension_installer, function(response){
                    $("#body").removeClass("container");
                    $("#body").css("text-align","");
                    $("#body").css("padding","");
                    $("#body").html(response);
                }).error(function(){
                    $("#body").html("<h4>:-( unable to load extension's installer</h4><h5>please check your extension configuration</h5>");
                });
            } else
            {
                $("#body").html("<h4>:-( Oops, your extension doesn't have an installer</h4>");
            }
        });
    }
    else
    {
        $("#body").addClass("container");
        $("#body").css("text-align","center");
        $("#body").css("padding","45px 0 45px 0");
        $("#body").html("<h3>:-( No extensions were installed</h3><h4>or, you haven't chosen any from the list</h4>");
    }

});