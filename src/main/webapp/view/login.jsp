<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="renderer" content="webkit|ie-comp|ie-stand">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
<meta http-equiv="Cache-Control" content="no-siteapp" />
<link rel="shortcut icon" href="favicon.ico"/>
<link rel="bookmark" href="favicon.ico"/>
<link href="h-ui/css/H-ui.min.css" rel="stylesheet" type="text/css" />
<link href="h-ui/css/H-ui.login.css" rel="stylesheet" type="text/css" />
<link href="h-ui/lib/icheck/icheck.css" rel="stylesheet" type="text/css" />
<link href="h-ui/lib/Hui-iconfont/1.0.1/iconfont.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">

<script type="text/javascript" src="easyui/jquery.min.js"></script> 
<script type="text/javascript" src="h-ui/js/H-ui.js"></script> 
<script type="text/javascript" src="h-ui/lib/icheck/jquery.icheck.min.js"></script> 

<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>

<script type="text/javascript">
	$(function(){

      $("#loginform").show();
      $("#registerForm").hide();
		
		//登录
		$("#submitBtn").click(function(){
			var data = $("#form").serialize();
			$.ajax({
				type: "post",
				url: "LoginServlet?oper=login",
				data: data, 
				dataType: "text", //返回数据类型
				success: function(msg){
					if("vcodeError" == msg){
						$.messager.alert("消息提醒", "验证码错误!", "warning");
						//$("#vcodeImg").click();//切换验证码
						$("input[name='vcode']").val("");//清空验证码输入框
					} else if("loginError" == msg){
						$.messager.alert("消息提醒", "用户名或密码错误!", "warning");
						//$("#vcodeImg").click();//切换验证码
						$("input[name='vcode']").val("");//清空验证码输入框
					} else if("loginSuccess" == msg){
						window.location.href = "SystemServlet?method=toAdminView";
					} else{
						alert(msg);
					} 
				}
				
			});
		});

      //注册
      $("#register").click(function(){
        let username = $("#regiUsername").val();
        let name = $("#regiName").val();
        let password = $("#regiPassword").val();
        let userType = $("#regiUserType").val();
        let mobile = $("#mobile").val();
        let passwordConfirm = $("#regiPasswordConfirm").val();
        if(username == ''){
          $.messager.alert("消息提醒","用户名不能为空","warning");
          return;
        }
        if(name == ''){
          $.messager.alert("消息提醒","姓名不能为空","warning");
          return;
        }
        if(password == ''){
          $.messager.alert("消息提醒","密码不能为空","warning");
          return;
        }
        if(userType === null){
          $.messager.alert("消息提醒","类型不能为空","warning");
          return;
        }
        if(mobile == ''){
          $.messager.alert("消息提醒","手机号不能为空","warning");
          return;
        }
        if(password != passwordConfirm){
          $.messager.alert("消息提醒","两次密码不一致","warning");
          return;
        }
        $.ajax({
          type: "post",
          url: "LoginServlet?oper=register",
          data: {
            username: $("#regiUsername").val(),
            name: $("#regiName").val(),
            password: $("#regiPassword").val(),
            userType: $("#regiUserType").combobox('getValue'),
            mobile: $("#regiMobile").val()
          },
          success: function(msg){
            if("loginSuccess" == msg){
              window.location.href = "SystemServlet?method=toAdminView";
            } else{
              console.log(msg);
              alert(msg);
            }
          }

        });
      });
		
		//设置复选框
		$(".skin-minimal input").iCheck({
			radioClass: 'iradio-blue',
			increaseArea: '25%'
		});
	})

    function toRegisterDIV(){
        $("#loginform").hide();
        $("#registerForm").show();
    }
</script> 
<title>登录|自习室预占座系统</title>
<meta name="keywords" content="自习室预占座系统">
</head>
<body>

<div class="header" style="padding: 0;">
	<h2 style="color: white; width: 400px; height: 60px; line-height: 60px; margin: 0 0 0 30px; padding: 0;">自习室预占座系统</h2>
</div>
<div class="loginWraper">

  <%--登录div--%>
  <div id="loginform" class="loginBox">
    <form id="form" class="form form-horizontal" method="post">
      <div class="row cl">
        <label class="form-label col-3"><i class="Hui-iconfont">&#xe60d;</i></label>
        <div class="formControls col-8">
          <input id="username" name="username" type="text" placeholder="账号" class="input-text size-L">
        </div>
      </div>
      <div class="row cl">
        <label class="form-label col-3"><i class="Hui-iconfont">&#xe60e;</i></label>
        <div class="formControls col-8">
          <input id="password" name="password" type="password" placeholder="密码" class="input-text size-L">
        </div>
      </div>
      
      <div class="row">
        <div class="formControls col-8 col-offset-3">
          <input id="submitBtn" type="button" class="btn btn-success radius size-L" value="&nbsp;登&nbsp;&nbsp;&nbsp;&nbsp;录&nbsp;">
          <a href="#" onclick="toRegisterDIV()" style="margin-left: 50px;color: #b94a48">注册</a>
        </div>
      </div>
    </form>
  </div>

    <div id="registerForm" class="registerBox">
      <form id="regiForm" class="form form-horizontal" method="post">
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">账号</i></label>
          <div class="formControls col-8">
            <input id="regiUsername" type="text" placeholder="账号" class="input-text size-L" data-options="required:true, missingMessage:'不能为空'">
          </div>
        </div>
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">姓名</i></label>
          <div class="formControls col-8">
            <input id="regiName" type="text" placeholder="姓名" class="input-text size-L">
          </div>
        </div>
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">密码</i></label>
          <div class="formControls col-8">
            <input id="regiPassword" type="password" placeholder="密码" class="input-text size-L">
          </div>
        </div>
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">确认密码：</i></label>
          <div class="formControls col-8">
            <input id="regiPasswordConfirm" type="password" placeholder="再输一次密码" class="input-text size-L">
          </div>
        </div>
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">手机号</i></label>
          <div class="formControls col-8">
            <input id="regiMobile" type="text" placeholder="手机号" class="input-text size-L">
          </div>
        </div>
        <div class="row cl">
          <label class="form-label col-3"><i class="Hui-iconfont">类型</i></label>
          <div class="formControls col-8">
            <select id="regiUserType" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30">
              <option></option>
              <option value="2">学生</option>
              <option value="3">老师</option>
            </select>
          </div>
        </div>

        <div class="row">
          <div class="formControls col-8 col-offset-3">
            <input id="register" type="button" class="btn btn-success radius size-L" value="&nbsp;注&nbsp;&nbsp;&nbsp;&nbsp;册&nbsp;">
          </div>
        </div>
      </form>
    </div>
</div>

</body>
</html>