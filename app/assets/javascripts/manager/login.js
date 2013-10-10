function generate_captcha(){
    $("#captchaText").text("...");
    $.get("/manager/captcha/services/generate", function(response){
        if (response.status == "success")
            $("#captchaText").text(response.data.trim());
        else
            $("#captchaText").text("...");
    }).error(function(){
            $("#captchaText").text("...");
        });
}

$(function () {
    Messenger.options = {
        extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right',
        theme: 'air'
    };

    if (window.location.hash == '#userRegistration')
    {
        $("#userRegistration").modal("show");
    }

    $("#resetPasswordModal").on("shown", function () {
        // don't do anything
    });

    $("#resetPasswordModal").on("hidden", function () {
        $("#resetEmail").val("");
    });

    $("#resetPasswordDetailedModal").on("shown", function () {
        // don't do anything
    });

    $("#resetPasswordDetailedModal").on("hidden", function () {
        $("#requestCode").val("");
        $("#resetPassword").val("");
        $("#resetPasswordConfirmation").val("");
    });

    $("#beginResetPasswordBtn").on("click", function () {
        var $this = $(this)
        if ($("#resetEmail").val().length > 0) {
            $($this.prev("button")).hide();
            $this.text("processing...");
            $this.attr("disabled", "disabled");
            $.post("/manager/u/services/request_pass_reset",
                {
                    "email": $("#resetEmail").val().trim()
                },function (response) {
                    if (response.status == "success") {
                        $('#resetPasswordModal').modal('hide');
                        $this.text("proceed...");
                        $this.removeAttr("disabled");
                        $($this.prev("button")).show();
                        $('#resetPasswordDetailedModal').modal({ backdrop : "static", keyboard : false });
                        $('#resetPasswordDetailedModal').modal('show');
                        Messenger().post("Your request has been processed; please check your registered mailbox for details and complete \"Step 2\"");
                    }
                    else {
                        $this.text("proceed...");
                        $this.removeAttr("disabled");
                        $($this.prev("button")).show();
                        Messenger().post(response.message);
                    }

                }).error(function () {
                    $this.text("proceed...");
                    $this.removeAttr("disabled");
                    $($this.prev("button")).show();
                    Messenger().post("Unable to process your request at the moment, please check back later")
                });
        } else
            Messenger().post(":-( That little textbox must be filled if you want to proceed");
    });

    $("#doResetPasswordBtn").on("click", function () {
        var $this = $(this);
        var requestCode = $("#requestCode").val(),
            newPassword = $("#resetPassword").val(),
            newPasswordConfirmation = $("#resetPasswordConfirmation").val();

        $("#doResetPasswordBtn").text("processing...");
        $("#doResetPasswordBtn").attr("disabled", "disabled");
        $($this.prev("button")).hide();
        if (requestCode.length > 0) {
            if (newPassword.length > 0 && newPasswordConfirmation.length > 0) {
                $.post("/manager/u/services/do_pass_reset", {
                    "requestCode": requestCode,
                    "newPassword": newPassword,
                    "newPasswordConfirmation": newPasswordConfirmation
                }, function (response) {
                    if (response.status == "success") {
                        $("#doResetPasswordBtn").text("proceed...");
                        $("#doResetPasswordBtn").removeAttr("disabled");
                        $($this.prev("button")).show();
                        $("#resetPasswordDetailedModal").modal('hide');
                        Messenger().post(":-) Your password has been successfully changed!");
                    }
                    else {
                        $("#doResetPasswordBtn").text("proceed...");
                        $("#doResetPasswordBtn").removeAttr("disabled");
                        $($this.prev("button")).show();
                        Messenger().post(response.message);
                    }
                })
            }
            else {
                $("#doResetPasswordBtn").text("proceed...");
                $("#doResetPasswordBtn").removeAttr("disabled");
                $($this.prev("button")).show();
                Messenger().post("Either new password or new password confirmation is missing")
            }
        }
        else {
            $("#doResetPasswordBtn").text("proceed...");
            $("#doResetPasswordBtn").removeAttr("disabled");
            $($this.prev("button")).show();
            Messenger().post("Request code is missing");
        }
    });

    $("#userRegistration").on("hidden", function(){
        $("#adminModalAccountName").val("");
        $("#adminModalAccountPass").val("");
        $("#adminModalAccountPassConfirm").val("");
        $("#btnUserRegCancelBtn").removeAttr("disabled");
        $("#btnUserRegCreateBtn").removeAttr("disabled");
        $("#btnUserRegCreateBtn").text("create");
        $("#captchaText").text("...");
    });

    $("#userRegistration").on("shown", function(){
        generate_captcha();
    });

    $("#btnUserRegCreateBtn").on("click", function(e){
        e.stopPropagation();

        var errors = "";
        /*if ($("#adminModalAccountName").val().length < 5)
            errors += "login name is too short or empty<br />";
        if ($("#adminModalAccountEmail").val().length > 0) {
            var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/

            if (!emailPattern.test($("#adminModalAccountEmail").val()))
                errors += "login email is not valid<br />";
        } else
            errors += "login email is empty<br />";
        if ($("#adminModalAccountCaptcha").val().length == 0)
            errors += "captcha is not filled out<br />";
        if ($("#adminModalAccountPass").val().length < 4)
            errors += "login password is too short (4 chars) or empty<br />";
        if ($("#adminModalAccountPass").val().indexOf(' ') >= 0)
            errors += "login password contains spaces<br />";
        if ($("#adminModalAccountPassConfirm").val().length == 0)
            errors += "login password (confirmed) is empty<br />";
        if ($("#adminModalAccountPassConfirm").val() != $("#adminModalAccountPass").val())
            errors += "login passwords don't match<br />"*/

        if (errors.length > 0)
            Messenger().post(errors);
        else
        {
            var newUser = {
                "login" : $("#adminModalAccountName").val().trim(),
                "email" : $("#adminModalAccountEmail").val().trim(),
                "password" : $("#adminModalAccountPassConfirm").val(),
                "password_confirmation": $("#adminModalAccountPassConfirm").val()
            };

            $.post("/manager/captcha/services/verify", {
                'captcha' : $("#adminModalAccountCaptcha").val().trim()
            }, function(response){
                if (response.status == "passed")
                {
                    $.post("/manager/users/only", {
                        "newUser" : newUser
                    }, function(response){
                        if (response.status == 'success')
                        {
                            $("#userRegistration").modal("hide");
                            Messenger().post({ message : "user has been created",
                                hideAfter : 3600,
                                showCloseButton: true });
                        }
                        else
                        {
                            generate_captcha();
                            Messenger().post({ message : "unable to process your request, please try again with different email and login",
                                type : "error" });
                        }
                    }).error(function(){
                            Messenger().post({ message : "there was a problem when your request is being processed",
                                type : "error" });
                    });
                }
                else
                    generate_captcha();
            }).error(function(){
                Messenger().post("unable to contact server");
            });

        }
    });
});