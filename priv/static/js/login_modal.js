function handle_login()
{
    var LOGIN_SUCCESS = 0;
    var EMAIL_NOT_REGISTER = 1;
    var PASSWORD_WRONG = 2;

    $.post("/account/login",
           {
               name:$("#name").val(),
               password:$("#pw1").val()
           },
           function(data){
               result = data.result;
               if (result == "success") {
                   location.href = "/";
               }
               else if (result == "nameNotExist"){
                   $("#error-text").html("用户名不存在，请向管理员申请");
               }
               else if (result == "passwordWrong") {
                   $("#error-text").html("密码错误");
               }
           });
}

function validate_and_login()
{
    $('#loginForm')
    .bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            name: {
                validators: {
                    notEmpty: {message: '用户名不能为空'}
                }
            },
            password: {
                validators: {
                    notEmpty: {message: '密码不能为空'},
                    stringLength: {min:6, max:36},
                    different: {field: 'name', message: '密码不能和名字一样'}
                }
            }
        }
    })
    .on('success.form.bv', function(e) {
        console.log("here****");
        // Prevent form submission
        e.preventDefault();
        //var $form        = $(e.target),
        //validator    = $form.data('bootstrapValidator'),
        //submitButton = validator.getSubmitButton();
        handle_login();
    });
}
