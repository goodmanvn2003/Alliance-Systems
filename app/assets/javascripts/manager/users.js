var groupsCached = "", groupsAssignCached = "";

function getSelectedGroupFromList() {
    selectedGroup = $($("li.groupList").filter(function (index) {
        return $(this).hasClass("active");
    }).find("a:first")).attr("data-group-id");

    return selectedGroup;
}

function refreshUserListForGroup(groupId) {
    $.getJSON("/manager/u/services/list/" + groupId,function (response) {
        $("#uList li:not(:first)").remove();

        if (response.status == "success") {
            var data = response.data;

            for (var i = 0; i < data.length; i++) {
                var cloned = $("#userDummy").clone();
                $($(cloned).find("#userDummyName")).text(data[i].login);
                $($(cloned).find("#userDummyEmail")).text(data[i].email);
                $($(cloned).find("#userDummyRoleList")).html(groupsCached);
                $($(cloned).find("#userDummyRoleAssignList")).html(groupsAssignCached);
                $($(cloned).find(".aUserModification")).attr("data-update-id", data[i].id);
                $($(cloned).find(".aUserModification")).attr("data-update-email", data[i].email);
                $($(cloned).find(".aUserRoleModification")).attr("data-update-id", data[i].id);
                $($(cloned).find(".aUserRoleAssignment")).attr("data-update-id", data[i].id);
                $($(cloned).find(".aUserRemoval")).attr("data-delete-id", data[i].id);
                $(cloned).css("display", "block");
                $(cloned).removeAttr("style");
                $(cloned).removeAttr("id");

                $("#uList li:first").after(cloned);
            }
        }
        else
            Messenger().post("Unable to retrieve a list of users");
    }).error(function () {
            Messenger().post("Unable to contact server");
        });

}

$(function () {
    groupsCached = $($("#userDummy").find("#userDummyRoleList")).html();
    groupsAssignCached = $($("#userDummy").find("#userDummyRoleAssignList")).html();

    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    $(".groupList").on("click", function () {
        $(".groupList").removeClass("active");
        $(this).addClass("active");

        Messenger.options = {
            extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
            theme: 'air'
        };

        // Load users for such a group
        var groupId = $($(this).find("a:first")).attr("data-group-id");
        refreshUserListForGroup(groupId);
    });

    $("#userCreation").on("hidden", function (e) {
        $("#userCreateClose").removeAttr("disabled");
        $("#userCreateBtn").removeAttr("disabled");
    });

    $("#userCreateBtn").on("click", function (e) {
        e.stopPropagation();
        var $this = $(this);
        var newPassword = $($("#userCreation").find("#newPassword")).val();

        var newUser = {
            "login": $($("#userCreation").find("#newLogin")).val(),
            "email": $($("#userCreation").find("#newEmail")).val(),
            "password": $($("#userCreation").find("#newPassword")).val(),
            "password_confirmation": $($("#userCreation").find("#newPasswordConfirmation")).val()
        };

        var errors = "";
        // if (newPassword.indexOf(' ') > -1)
        //    errors += "password contains spaces<br />";

        if (errors.length == 0)
        {
            $("#userCreateClose").attr("disabled", "disabled");
            $this.attr("disabled", "disabled");

            $.post("/manager/users",
                {
                    "newUser": newUser,
                    "newRole": $($("#userCreation").find("#newGroup")).val()
                }
                ,
                function (response) {
                    if (response.status == "success") {
                        Messenger().post("User is created");
                        $("#userCreation").modal("hide");

                        if (getSelectedGroupFromList() == $($("#userCreation").find("#newGroup")).val()) {
                            refreshUserListForGroup(getSelectedGroupFromList());
                        }
                    }
                    else {
                        $("#userCreateClose").removeAttr("disabled");
                        $this.removeAttr("disabled");
                        Messenger().post(response.message);
                    }
                }).error(function () {
                    $("#userCreateClose").removeAttr("disabled");
                    $this.removeAttr("disabled");
                    Messenger().post("Unable to contact server");
                });
        } else
            Messenger().post(errors);
    });

    $("#uList").on("click", ".aUserModification", function () {
        var $this = $(this);

        $("#userModification #userModifyBtn").attr("data-update-id", $this.attr("data-update-id"));
        $("#userModification #newEmail").val($this.attr("data-update-email"));
    });

    $("#uList").on("click", ".groupAssignList", function() {
        var $this = $(this);

        $("#userRoleAssignment #userRoleAssignBtn").attr("data-update-id", $($this.find("a:first")).attr("data-update-id"));
        $("#userRoleAssignment #userRoleAssignBtn").attr("data-group-id", $($this.find("a:first")).attr("data-group-id"));
    });

    $("#uList").on("click", ".aUserRemoval", function () {
        var $this = $(this);

        $("#userDeletion #userDeleteBtn").attr("data-delete-id", $this.attr("data-delete-id"));
    });

    $("#uList").on("click", ".groupModifyList", function () {
        var $this = $(this);

        $("#userRoleModification #userRoleModifyBtn").attr("data-update-id", $($this.find("a:first")).attr("data-update-id"));
        $("#userRoleModification #userRoleModifyBtn").attr("data-group-id", $($this.find("a:first")).attr("data-group-id"));
    });

    $("#userModification").on("hidden", function (e) {
        $($(this).find("#newEmail")).val("");
        $($(this).find("#oldPassword")).val("");
        $($(this).find("#newPassword")).val("");
        $($(this).find("#newPasswordConfirmation")).val("");
        $($(this).find("#userModifyBtn")).removeAttr("data-update-id");

        $("#userModifyClose").removeAttr("disabled");
        $("#userModifyBtn").removeAttr("disabled");
    });

    $("#userModification").on("click", "#userModifyBtn", function (e) {
        e.stopPropagation();
        var $this = $(this);
        var newPassword = $($("#userModification").find("#newPassword")).val();

        var updateUser = {
            "email": $($("#userModification").find("#newEmail")).val(),
            "password": $($("#userModification").find("#newPassword")).val(),
            "password_confirmation": $($("#userModification").find("#newPasswordConfirmation")).val()
        }

        var userId = $(this).attr("data-update-id");

        var errors = "";
        //if (newPassword.indexOf(' ') > -1)
        //    errors += "password contains spaces<br />";

        if (errors.length == 0)
            $.ajax({
                url: "/manager/users/" + userId,
                type: "PUT",
                cache: false,
                data: {
                    "id": userId,
                    "user": updateUser,
                    "oldPassword": $("#oldPassword").val()
                },
                beforeSend: function () {
                    $("#userModifyClose").attr("disabled", "disabled");
                    $this.attr("disabled", "disabled");
                },
                error: function () {
                    Messenger().post("Unable to contact server");
                },
                success: function (response) {
                    if (response.status == "success") {
                        Messenger().post("new informations were saved")
                        $("#userModification").modal("hide");
                        refreshUserListForGroup(getSelectedGroupFromList());
                    }
                    else {
                        $("#userModifyClose").removeAttr("disabled");
                        $this.removeAttr("disabled");
                        Messenger().post(response.message);
                    }
                }
            });
        else
            Messenger().post(errors);
    });

    $("#userDeletion").on("hidden", function () {
        $($(this).find("#userDeleteBtn")).removeAttr("data-delete-id");

        $("#userDeleteClose").removeAttr("disabled");
        $("#userDeleteBtn").removeAttr("disabled");
    });

    $("#userDeletion").on("click", "#userDeleteBtn", function (e) {
        e.stopPropagation();
        var $this = $(this);

        var userId = $(this).attr("data-delete-id");

        $.ajax({
            url: "/manager/site_users/" + userId,
            type: "DELETE",
            cache: false,
            beforeSend: function () {
                $("#userDeleteClose").attr("disabled", "disabled");
                $this.attr("disabled", "disabled");
            },
            error: function () {
                Messenger().post("Unable to contact server");
            },
            success: function (response) {
                if (response.status == "success") {
                    Messenger().post("user has just been removed")
                    $("#userDeletion").modal("hide");
                    refreshUserListForGroup(getSelectedGroupFromList());
                }
                else {
                    $("#userDeleteClose").removeAttr("disabled");
                    $this.removeAttr("disabled");
                    Messenger().post(response.messasge);
                }
            }
        });
    });

    $("#userRoleModification").on("hidden", function (e) {
        $("#userRoleModifyClose").removeAttr("disabled");
        $("#userRoleModifyBtn").removeAttr("disabled");
    });

    $("#userRoleModifyBtn").on("click", function (e) {
        e.stopPropagation();
        var $this = $(this);

        if (getSelectedGroupFromList() == $this.attr("data-group-id"))
            Messenger().post("User currently belongs to this group");
        else {
            $.ajax({
                url: "/manager/users/role/" + $this.attr("data-update-id"),
                cache: false,
                type: "PUT",
                data: {
                    "role": $this.attr("data-group-id"),
                    "roleOrig" : getSelectedGroupFromList()
                },
                beforeSend: function () {
                    $("#userRoleModifyClose").attr("disabled", "disabled");
                    $this.attr("disabled", "disabled");
                },
                error: function () {
                    $("#userRoleModifyClose").removeAttr("disabled");
                    $this.removeAttr("disabled");
                    Messenger().post("Unable to contact server");
                },
                success: function (response) {
                    if (response.status == "success") {
                        Messenger().post("New user role has been successfully changed");
                        $("#userRoleModification").modal("hide");
                        refreshUserListForGroup(getSelectedGroupFromList());
                    }
                    else {
                        $("#userRoleModifyClose").removeAttr("disabled");
                        $("#userRoleModifyClose").removeAttr("disabled");
                        $this.removeAttr("disabled");
                        Messenger().post(response.message);
                    }
                }
            });
        }

    });

    $("#userRoleAssignBtn").on("click", function(e){
        e.stopPropagation();
        var $this = $(this);

        if (getSelectedGroupFromList() == $this.attr("data-group-id"))
            Messenger().post("User currently belongs to this group");
        else
        {
            $.ajax({
                url: "/manager/r/services/assign/" + $this.attr("data-update-id"),
                cache: false,
                type: "PUT",
                data: {
                    "roles_id": $this.attr("data-group-id")
                },
                beforeSend: function () {
                    $("#userRoleAssignClose").attr("disabled", "disabled");
                    $this.attr("disabled", "disabled");
                },
                error: function () {
                    $("#userRoleAssignClose").removeAttr("disabled");
                    $this.removeAttr("disabled");
                    Messenger().post("Unable to contact server");
                },
                success: function (response) {
                    if (response.status == "success") {
                        Messenger().post("User role has been successfully assigned");
                        $("#userRoleAssignment").modal("hide");
                        refreshUserListForGroup(getSelectedGroupFromList());
                    }
                    else {
                        $("#userRoleAssignClose").removeAttr("disabled");
                        $this.removeAttr("disabled");
                        Messenger().post(response.message);
                    }
                }
            });
        }
    });

    $("#userRoleAssignment").on("shown", function(){
        $("#userRoleAssignClose").removeAttr("disabled");
        $("#userRoleAssignBtn").removeAttr("disabled");
    });

    /*$("#uList").on("click", "#userDummyBan", function(e){
     e.stopPropagation();

     Messenger().post("This feature is currently unavailable");
     });*/

    $("#userSearchText").on("keyup", function(e){
        e.stopPropagation();

        var key = (e.keyCode ? e.keyCode : e.which)
        var $this = $(this);

        if (key == 13)
        {
            if (/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test($this.val()))
            {

                $.post("/manager/u/services/list/filter", {
                    "email" : $(this).val()
                }, function(response){
                    if (response.status == "success")
                    {
                        foundUsers = response.data;
                        $("#uList li:not(:first)").remove();

                        // alert(response.state);

                        if (foundUsers.length > 0)
                        {
                            for (var i = 0; i < foundUsers.length; i++)
                            {
                                var cloned = $("#userDummy").clone();
                                var uEmail = foundUsers[i];

                                cloned.find(".userOperationsGroup").hide();
                                cloned.find(".userInvitationGroup").show();
                                cloned.find("#userDummyName").text("System User");
                                cloned.find("#userDummyName").show();
                                cloned.find("#userDummyEmail").text(foundUsers[i]);
                                cloned.find("#userDummyEmail").show();
                                cloned.find("#aUserRole").show();
                                cloned.show();

                                cloned.find(".aUserInvite").on("click", function(){

                                    var $thisInvite = $(this);

                                    var uRole = $($($thisInvite.parent("div")).find("#aUserRole")).val();
                                    $(this).attr("disabled","disabled");

                                    $.post("/manager/u/services/invite", {
                                        'email' : uEmail,
                                        'role' : uRole
                                    }, function(response){
                                        if (response.status == 'success')
                                        {
                                            $thisInvite.removeAttr("disabled");
                                            $thisInvite.html("<i class=\"icon-repeat\"></i>&nbsp;re-invite")
                                            Messenger().post("invitation has just been sent successfully");
                                        }
                                        else
                                        {
                                            $thisInvite.removeAttr("disabled");
                                            Messenger().post("unable to send invitation request to specified email");
                                        }

                                    }).error(function(){
                                            $thisInvite.removeAttr("disabled");
                                            Messenger().post("unable to contact server");
                                        });
                                });

                                $("#uList li:first").after(cloned);
                            }
                        } else
                        {

                            if (response.state == "nonexists")
                            {
                                var cloned = $("#userDummy").clone();

                                cloned.find(".userOperationsGroup").hide();
                                cloned.find(".userInvitationGroup").show();
                                cloned.find("#userDummyName").text("New User");
                                cloned.find("#userDummyName").show();
                                cloned.find("#userDummyEmail").text($this.val());
                                cloned.find("#userDummyEmail").show();
                                cloned.find("#aUserRole").show();
                                cloned.show();

                                cloned.find(".aUserInvite").on("click", function(){
                                    var $thisInvite = $(this);

                                    var sentEmail = cloned.find("#userDummyEmail").text();
                                    var uRole = $($($thisInvite.parent("div")).find("#aUserRole")).val();

                                    $(this).attr("disabled","disabled");

                                    $.post("/manager/u/services/invite", {
                                        'email' : sentEmail,
                                        'role' : uRole
                                    }, function(response){
                                        if (response.status == 'success')
                                        {
                                            $thisInvite.removeAttr("disabled");
                                            $thisInvite.html("<i class=\"icon-repeat\"></i>&nbsp;re-invite")
                                            Messenger().post("invitation has just been sent successfully");
                                        }
                                        else
                                        {
                                            $thisInvite.removeAttr("disabled");
                                            Messenger().post("unable to send invitation request to specified email");
                                        }

                                    }).error(function(){
                                            $thisInvite.removeAttr("disabled");
                                            Messenger().post("unable to contact server");
                                        });
                                });

                                $("#uList li:first").after(cloned);
                            }
                            else
                                Messenger().post("user with that email address has already been in workspace");
                        }
                    }
                    else
                    {
                        Messenger().post("unable to get a list of users");
                    }
                }).error(function(){
                        Messenger().post("unable to contact server");
                    });

            } else
                Messenger().post("that was not a valid email address");

        }

    });
});