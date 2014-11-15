function handle_manager(){
    $('button[data-loading-text]').click(function () {
        var btn = $(this).button('loading');
        //setTimeout(function () {
        //    btn.button('reset');
        //}, 3000);
    });

    is_login = $('#svr-data').data("is_login");
    $("#reload_confs").click(function(){
        console.log("reload_confs");
        if (is_login){
            $.post("/manager/reload_confs",
                   {},
                   function(data){
                       $('#reload_confs').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           $("#errorMsg").html("不能连接服务器, 未开启或者异常!")
                       }
                       else if (result == "success"){
                           $("#errorMsg").html("");
                           location.reload();
                       }
                   }
                  );
        }
        else{
            console.log("not login");
            $('#reload_confs').button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    $("#reload_svr").click(function(){
        if (is_login){
            $.post("/manager/reload_svr",
                   {},
                   function(data){
                       $('#reload_svr').button('reset');
                       result = data.result;
                       if (result == "serverNotLive"){
                           $("#errorMsg").html("不能连接服务器, 未开启或者异常!")
                       }
                       else if (result == "success"){
                           $("#errorMsg").html("");
                           location.reload();
                       }
                   }
                  );
        }
        else{
            $('#reload_svr').button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    $('button[delete-crash-id]').click(function () {
        var crash_id = $(this).attr('delete-crash-id');
        if (is_login){
            $.post("/manager/del_crash",
                   {crash_id: crash_id},
                   function(data) {
                       result = data.result;
                       if (result == "success") {
                           location.reload();
                       }
                   }
                  )
        }
        else {
            $(this).button('reset');
            $('#loginModal').modal("toggle");
        }
    });

    var total_pages = $('#pageInfo').data('total-pages');
    console.log("*****total_pages", total_pages);

    var page_num = $('#pageInfo').data('page-num');


    if ($('#pagination').length > 0) {
        $('#pagination').twbsPagination({
            totalPages: total_pages,
            visiblePages: 6,
            startPage: page_num,
            first: '&laquo;首页',
            last: '最后&raquo;',
            prev: '&lsaquo;前一页',
            next: '后一页&rsaquo;',
            href: '?page={{number}}',
            onPageClick: function (event, page) {
                console.log(page);
                //url = "/game/images/" + game_id + "/" + page;
                //location.href = url;
            }
        });
    }

}
