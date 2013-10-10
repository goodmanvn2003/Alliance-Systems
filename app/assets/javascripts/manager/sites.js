function refreshSitesList(isSelectCurrent, siteid)
{
    $("#sites").html("<option value=''>refreshing...</option>");
    $("#sites").attr("disabled","disabled");

    $.getJSON("/manager/site/services/all", function(response){
        if (response.status == "success")
        {

            $("#sites").html("<option value=''>[no selection]</option>");

            for (var i = 0; i < response.data.length; i++)
            {
                var element = $("<option></option>");
                element.attr("value", response.data[i].id);
                element.text(response.data[i].name);
                $("#sites").append(element);
            }

            if (isSelectCurrent)
                $("#sites").val(siteid);

            $("#sites").removeAttr("disabled");
        }
        else
        {
            $("#sites").html("<option value=''>error when retrieving...</option>");
            Messenger().post("Unable to get a list of sites");
        }

    }).error(function(){
        $("#sites").html("<option value=''>error when retrieving...</option>");
        Messenger().post("Unable to contact server");
    });
}

$(function(){

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $("#sites").on("change", function(){
        $("#settingsList li").removeClass("active");
        $("#panelContainer").children("div").fadeOut("fast");
        $("#sitename").val("");
        $("#sitedesc").val("");
        $("#sitecreationdate").text("");
    });

    $("#settingsList li").on("click", function(e){

        if ($(this).hasClass("active") == false)
        {
            var settings = $(".panel");
            var selectedSite = $("#sites").val();
            var element = null;

            $("#settingsList li").removeClass("active");

            if (selectedSite.length > 0)
            {
                for (var i = 0; i < settings.length; i++)
                {
                    if ($(settings[i]).attr("id") == $(this).attr("data-key"))
                    {
                        $(this).addClass("active");
                        element = settings[i];
                        break;
                    }
                }

                // Load site data from server
                $.getJSON("/manager/site/services/info/" + selectedSite + "/" + $(this).attr("data-key"), function(response){
                    if (response.status == "success")
                    {
                        data = JSON.parse(response.data.value);

                        $("#sitename").val(data.name);
                        $("#sitedesc").val(data.description);
                        $("#sitecreationdate").text((new Date(response.data.created_at)).toUTCString());
                        $("#prefsSaveBtn").attr("data-id",response.data.id);

                        if ($("#panelContainer").children("div:visible").length == 0)
                        {
                            $(element).fadeIn("fast");
                        }
                        else
                        {
                            $(".panel:visible").fadeOut("fast", function(){
                                if (element != null)
                                    $(element).fadeIn("fast");
                            });
                        }
                    }
                    else
                    {
                        Messenger().post("Unable to get site information");
                    }
                }).error(function(){
                        Messenger().post("Unable to contact server");
                    });

            }
            else
            {
                Messenger().post("please select a site to configure");
            }

        }
    });

    $("#prefsSaveBtn").on("click", function(e){
        var siteid = $(this).attr("data-id");
        var selectedid = $("#sites").val();
        var updatedData = {
            'name' : $("#sitename").val().trim(),
            'description': $("#sitedesc").val().trim()
        }
        var dataObj = {
            'value' : JSON.stringify(updatedData)
        }

        if (updatedData.name.trim().length > 6)
        {
            $.ajax({
                url: "/manager/configurations/" + siteid,
                cache: false,
                type: "PUT",
                data: {
                    'data' : dataObj,
                    'flag' : 'site'
                },
                error: function(){
                    $("#prefsSaveBtn").removeAttr("disabled");
                    $("#prefsSaveBtn").text("save changes");
                    Messenger().post("Unable to contact server");
                },
                beforeSend: function(){
                    $("#prefsSaveBtn").attr("disabled","disabled");
                    $("#prefsSaveBtn").text("saving...");
                },
                success: function(response){
                    if (response.status == 'success')
                    {
                        $("#prefsSaveBtn").removeAttr("disabled");
                        $("#prefsSaveBtn").text("save changes");
                        refreshSitesList(true, selectedid);

                        // Update sitename in top bar
                        $("#brandSitename").text(response.extra.new_sitename);
                        Messenger().post("site information is updated successfully");
                    }
                    else
                    {
                        $("#prefsSaveBtn").removeAttr("disabled");
                        $("#prefsSaveBtn").text("save changes");
                        Messenger().post("Unable to update site information");
                    }
                }
            });
        } else if (updatedData.name.trim().length < 6 && updatedData.name.trim().length > 0)
        {
            Messenger().post("name is too short");
        }
        else
        {
            Messenger().post("name cannot be empty");
        }

    });

    $("#addSiteModal").on("hidden", function(){
        $("#siteModalName").val("");
        $("#siteModalDescription").val("");
        $("#siteCreateBtn").removeAttr("disabled");
        $("#siteCreateBtn").text("create");
        $("#siteCancelBtn").removeAttr("disabled");
    });

    $("#siteCreateBtn").on("click", function(e){
        e.stopPropagation();

        if ($("#siteModalName").val().length > 6)
        {
            $("#siteCreateBtn").text("creating...");
            $("#siteCreateBtn").attr("disabled","disabled");
            $("#siteCancelBtn").attr("disabled","disabled");
            $.post("/manager/site/services/create",{
                'name' : $("#siteModalName").val(),
                'description' : $("#siteModalDescription").val()
            }, function(response){
                if (response.status == 'success')
                {
                    $("#addSiteModal").modal("hide");
                    refreshSitesList(false, null);
                    Messenger().post("site is successfully created");
                }
                else
                {
                    $("#siteCreateBtn").removeAttr("disabled");
                    $("#siteCancelBtn").removeAttr("disabled");
                    $("#siteCreateBtn").text("create");
                    Messenger().post("unable to create new site");
                }
            }).error(function(){
                    $("#siteCreateBtn").removeAttr("disabled");
                    $("#siteCancelBtn").removeAttr("disabled");
                    $("#siteCreateBtn").text("create");
                    Messenger().post("unable to contact server");
                });
        } else
        {
            Messenger().post("site name is empty or too short");
        }

    });

    $("#removeSiteModal").on("hidden", function(){
        $("#siteRemoveCancelBtn").removeAttr("disabled");
        $("#siteRemoveBtn").removeAttr("disabled");
    });

    $("#siteRemoveBtn").on("click", function(e){
        e.stopPropagation();

        var id = $("#sites").val();

        if (id.length > 0)
        {
            $.ajax({
                url: "/manager/site/services/delete/" + id,
                cache: false,
                type: "DELETE",
                beforeSend: function(){
                    $("#siteRemoveCancelBtn").attr("disabled","disabled");
                    $("#siteRemoveBtn").attr("disabled","disabled");
                },
                error: function(){
                    $("#siteRemoveCancelBtn").removeAttr("disabled");
                    $("#siteRemoveBtn").removeAttr("disabled");
                },
                success: function(response){
                    if (response.status == "success")
                    {
                        $("#removeSiteModal").modal("hide");
                        refreshSitesList(false, null);

                        $("#settingsList li").removeClass("active");
                        $("#panelContainer").children("div").fadeOut("fast");
                        $("#sitename").val("");
                        $("#sitedesc").val("");
                        $("#sitecreationdate").text("");

                        Messenger().post("site is removed successfully");
                    }
                    else if (response.status == "redirect")
                    {
                        Messenger().post("redirecting...");
                        window.location = response.url;
                    }
                    else if (response.status == "failure")
                    {
                        $("#siteRemoveCancelBtn").removeAttr("disabled");
                        $("#siteRemoveBtn").removeAttr("disabled");
                        Messenger().post("unable to remove site");
                    }
                }
            })
        } else
        {
            Messenger().post("select a site from the box to delete");
        }

    });

});
