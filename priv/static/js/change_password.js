function validate_and_change()
{
    $('#changePassword').click(function(event){
        console.log("*****here");
        event.preventDefault();
        $("#changePasswordModal").modal('toggle');
    });

    $('#changePasswordForm')
    .bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            oriPassword: {
                validators: {
                    notEmpty: {message: '密码不能为空'},
                    stringLength: {min:6, max:20},
                    different: {field: 'pw1', message: '新密码得和原始密码不一样'},
                }
            },
            pw1: {
                validators: {
                    notEmpty: {message: '新密码不能为空'},
                    stringLength: {min:6, max:20},
                    different: {field: 'oriPassword', message: '新密码得和原始密码不一样'},
                    identical: {field: 'pw2', message: '两次输入的密码不一样'}
                }
            },
            pw2: {
                validators: {
                    notEmpty: {message: '新密码不能为空'},
                    stringLength: {min:6, max:20},
                    different: {field: 'oriPassword', message: '新密码得和原始密码不一样'},
                    identical: {field: 'pw1', message: '两次输入的密码不一样'}
                }
            }
        }
    })
    .on('success.form.bv', function(e) {
        // Prevent form submission
        e.preventDefault();
        //var $form        = $(e.target),
        //validator    = $form.data('bootstrapValidator'),
        //submitButton = validator.getSubmitButton();
        var ori_pw = $("input[name='oriPassword']").val();
        var pw1 = $("input[name='pw1']").val();
        handle_change(ori_pw, pw1);
    });
}

function handle_change(ori_password, new_password)
{
    $.post("/account/change_password",
           {"ori_password":ori_password, "new_password":new_password},
           function(data){
               var result = data.result;
               if (result == "success"){
                   location.href = "/";
               }
               else if (result == "passwordWrong"){
                   $("#change-error-text").html("密码错误");
               }
           }
          );
}
