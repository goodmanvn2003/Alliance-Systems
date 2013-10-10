function observeEditState(object){
    var dataEditState = $(object).attr("data-edit-state");

    if (dataEditState == "true")
    {
        $($(object).find("i").first()).removeClass();
        $($(object).find("i").first()).addClass("icon-pencil");
        $(object).attr("data-edit-state","false");
        $($($(object).siblings("span:first")).find("input[type=text]:first")).hide(1, function(){
            $($($(object).siblings("span:first")).find("a:first")).show();
            $($($(object).siblings("span:first")).find("a:first")).focus();
        });

        return false;
    }else
    {
        $($(object).find("i").first()).removeClass();
        $($(object).find("i").first()).addClass("icon-ok");
        $(object).attr("data-edit-state","true");
        $($($(object).siblings("span:first")).find("a:first")).hide(1, function(){
            $($($(object).siblings("span:first")).find("input[type=text]:first")).width($(this).width()+32);
            $($($(object).siblings("span:first")).find("input[type=text]:first")).show();
            $($($(object).siblings("span:first")).find("input[type=text]:first")).val($(this).text());
            $($($(object).siblings("span:first")).find("input[type=text]:first")).focus();
        });

        return true;
    }
}

function getUserAssignedRoles(elem)
{
    $(elem).text("loading...");
    $.getJSON("/manager/r/services/list_profile", function(response){
        if (response.status == "success")
        {
            var html = response.data.join(', ');
            $(elem).text(html);
        }
        else
        {
            Messenger().post("unable to retrieve assigned role list");
        }
    }).error(function(){
        Messenger().post("unable to contact server");
    });
}

$(function(){

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $("#adminRoleAssign").on("click",function(){
        if ($("#selectAssignedRoles").is(":visible"))
        {
            $($(this).find("i:first")).removeClass("icon-ok");
            $($(this).find("i:first")).addClass("icon-pencil");
            $("#selectAssignedRoles").hide();
            $("#assignedRoles").show();
        } else
        {
            $($(this).find("i:first")).removeClass("icon-pencil");
            $($(this).find("i:first")).addClass("icon-ok");
            $("#selectAssignedRoles").show();
            $("#assignedRoles").hide();
        }
    });

    // Load a list of user assigned roles
    getUserAssignedRoles($("#assignedRoles"));

    $("#emailEdit").on("click", function(e){
        e.stopPropagation();
        var $this = $(this);
        var tEmail = $("#emailTxt").val().trim();

        var state = observeEditState($(this));
        if (state == false)
        {
            var updateObject = {
                'email' : $("#emailTxt").val().trim()
            }

            var patt = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/g
            if (patt.test(updateObject.email))
            {
                $.ajax({
                    url: "/manager/users/self/info",
                    cache: false,
                    type: "PUT",
                    data: {
                        'data' : updateObject
                    },
                    beforeSend: function(){
                        $("#emailTxt").attr("disabled","disabled");
                        $("#emailTxt").val("updating...");
                    },
                    error: function(){
                        $("#emailTxt").val($("#aEmail").text());
                        $("#emailTxt").removeAttr("disabled");
                        $("#emailTxt").hide(1, function(){
                            $("#aEmail").show();
                        });
                        Messenger().post("unable to contact server");
                    },
                    success: function(response){
                        if (response.status == "success")
                        {
                            $("#aEmail").text(tEmail);
                            $("#emailTxt").removeAttr("disabled");
                            $("#emailTxt").hide(1, function(){
                                $("#aEmail").show();
                            });
                            Messenger().post("user information is successfully updated");
                        }
                        else
                        {
                            $("#emailTxt").val($("#aEmail").text());
                            $("#emailTxt").removeAttr("disabled");
                            $("#emailTxt").hide(1, function(){
                                $("#aEmail").show();
                            });
                            Messenger().post("unable to update user information");
                        }
                    }
                });
            } else
                Messenger().post("email is invalid");

        }
    });

});
