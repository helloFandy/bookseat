<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>学生列表</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {	
		//datagrid初始化 
	    $('#dataList').datagrid({ 
	        title:'用户列表',
	        iconCls:'icon-more',//图标 
	        border: true, 
	        collapsible:false,//是否可折叠的 
	        fit: true,//自动大小 
	        method: "post",
	        url:"UserServlet?oper=UserList&t="+new Date().getTime(),
	        idField:'id', 
	        singleSelect:false,//是否单选 
	        pagination:true,//分页控件 
	        rownumbers:true,//行号 
	        sortName:'id',
	        sortOrder:'DESC', 
	        remoteSort: false,
	        columns: [[  
				{field:'chk',checkbox: true,width:50},
 		        {field:'id',title:'ID',width:50, sortable: true},    
 		        {field:'username',title:'账号',width:200, sortable: true},
 		        {field:'name',title:'姓名',width:200},
 		        {field:'userType',title:'身份',width:100,
					formatter: function(value,row,index){
						if (value == 1){
							return '管理员';
						} else if (value == 2){
							return '学生';
						}else if (value == 3){
							return '教师'
						}else {
							return 'not found'
						}
					}
				},
				{field:'password',title:'密码',width:200,hidden:true},
				{field:'mobile',title:'手机号',width:200},
				{field:'reputation',title:'信誉值',width:200}

	 		]], 
	        toolbar: "#toolbar",
	    });

	    //设置分页控件 
	    var p = $('#dataList').datagrid('getPager'); 
	    $(p).pagination({ 
	        pageSize: 10,//每页显示的记录条数，默认为10 
	        pageList: [10,20,30,50,100],//可以设置每页记录条数的列表 
	        beforePageText: '第',//页数文本框前显示的汉字 
	        afterPageText: '页    共 {pages} 页', 
	        displayMsg: '当前显示 {from} - {to} 条记录   共 {total} 条记录', 
	    });

	    //设置工具类按钮
	    $("#add").click(function(){
	    	$("#addDialog").dialog("open");
	    });

	    //修改
	    $("#edit").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	if(selectRows.length != 1){
            	$.messager.alert("消息提醒", "请选择一条数据进行操作!", "warning");
            } else{
		    	$("#editDialog").dialog("open");
            }
	    });

	    //删除
	    $("#delete").click(function(){
	    	var selectRows = $("#dataList").datagrid("getSelections");
        	var selectLength = selectRows.length;
        	if(selectLength == 0){
            	$.messager.alert("消息提醒", "请选择数据进行删除!", "warning");
            } else{
            	var numbers = [];
            	$(selectRows).each(function(i, row){
            		numbers[i] = row.sn;
            	});
            	var ids = [];
            	$(selectRows).each(function(i, row){
            		ids[i] = row.id;
            	});
            	$.messager.confirm("消息提醒", "将删除与学生相关的所有数据(包括成绩)，确认继续？", function(r){
            		if(r){
            			$.ajax({
							type: "post",
							url: "UserServlet?oper=DeleteUser",
							data: {sns: numbers, ids: ids},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("消息提醒","删除成功!","info");
									//刷新表格
									$("#dataList").datagrid("reload");
									$("#dataList").datagrid("uncheckAll");
								}else if(msg == "tch_limit"){
									$.messager.alert("消息提醒","删除失败,教师没有删除学生信息权限！","warning");
									return;
								}
								else{
									$.messager.alert("消息提醒","删除失败!","warning");
									return;
								}
							}
						});
            		}
            	});
            }
	    });
	  	
	  	function preLoadClazz(){
	  		$("#clazzList").combobox({
		  		width: "150",
		  		height: "25",
		  		valueField: "id",
		  		textField: "name",
		  		multiple: false, //可多选
		  		editable: false, //不可编辑
		  		method: "post",
		  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
		  		onChange: function(newValue, oldValue){
		  			//加载班级下的学生
		  			//$('#dataList').datagrid("options").queryParams = {clazzid: newValue};
		  			//$('#dataList').datagrid("reload");
		  		}
		  	});
	  	}
	  	
	  	//下拉框通用属性
	  	$("#add_clazzList, #edit_clazzList").combobox({
	  		width: "200",
	  		height: "30",
	  		valueField: "id",
	  		textField: "name",
	  		multiple: false, //可多选
	  		editable: false, //不可编辑
	  		method: "post",
	  	});
	  	
	  	
	  	$("#add_clazzList").combobox({
	  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
	  		onLoadSuccess: function(){
		  		//默认选择第一条数据
				var data = $(this).combobox("getData");;
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	  	
	  	
	  	$("#edit_clazzList").combobox({
	  		url: "ClazzServlet?method=getClazzList&t="+new Date().getTime()+"&from=combox",
			onLoadSuccess: function(){
				//默认选择第一条数据
				var data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);
	  		}
	  	});
	  	
	  	//设置添加学生窗口
	    $("#addDialog").dialog({
	    	title: "添加用户",
	    	width: 650,
	    	height: 460,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'添加',
					plain: true,
					iconCls:'icon-user_add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "UserServlet?oper=AddUser",
								data: $("#addForm").serialize(),
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","添加成功!","info");
										//关闭窗口
										$("#addDialog").dialog("close");
										//清空原表格数据
										$("#add_username").textbox('setValue', "");
										$("#add_name").textbox('setValue', "");
										$("#add_password").textbox('setValue', "");
										$("#add_userType").textbox('setValue', "1");
										
										//重新刷新页面数据
							  			$('#dataList').datagrid("reload");
									} else{
										$.messager.alert("消息提醒","添加失败!","warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'重置',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						$("#add_username").textbox('setValue', "");
						$("#add_name").textbox('setValue', "");
						$("#add_password").textbox('setValue', "");
						$("#add_userType").textbox('setValue', "管理员");
						$("#add_userType").val(1);
					}
				},
			]
	    });
	  	
	  	//设置编辑学生窗口
	    $("#editDialog").dialog({
	    	title: "修改用户信息",
	    	width: 650,
	    	height: 460,
	    	iconCls: "icon-edit",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'提交',
					plain: true,
					iconCls:'icon-user_add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "UserServlet?oper=EditUser&t="+new Date().getTime(),
								data: {
									id: $("#edit_id").textbox('getValue'),
									username: $("#edit_username").textbox('getValue'),
									name: $("#edit_name").textbox('getValue'),
									password: $("#edit_password").textbox('getValue'),
									userType: $("#edit_userType").combobox('getValue'),
									mobile: $("#edit_mobile").textbox('getValue'),
									reputation: $("#edit_reputation").textbox('getValue')
								},
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","更新成功!","info");
										//关闭窗口
										$("#editDialog").dialog("close");
										//刷新表格
										$("#dataList").datagrid("reload");
									} else{
										$.messager.alert("消息提醒","更新失败!","warning");
										return;
									}
								}
							});
						}
					}
				},
				{
					text:'重置',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						//清空表单
						$("#edit_username").textbox('setValue', "");
						$("#edit_name").textbox('setValue', "");
						$("#edit_password").textbox('setValue', "");
						$("#edit_userType").combobox('setValue',"1");
						$("#edit_mobile").textbox('setValue',"");
						$("#edit_reputation").textbox('setValue',"");
					}
				}
			],
			onBeforeOpen: function(){
				var selectRow = $("#dataList").datagrid("getSelected");
				var userType = "管理员";
				if (selectRow.userType == 2){
					userType = "学生";
				}else if (selectRow.userType == 3){
					userType = "教师";
				}
				//设置值
				$("#edit_id").textbox('setValue', selectRow.id);
				$("#edit_username").textbox('setValue', selectRow.username);
				$("#edit_name").textbox('setValue', selectRow.name);
				$("#edit_password").textbox('setValue', selectRow.password);
				$("#edit_userType").combobox('setValue',selectRow.userType);
				$("#edit_mobile").textbox('setValue',selectRow.mobile);
				$("#edit_reputation").combobox('setValue',selectRow.reputation);
			}
	    });

	    //搜索按钮监听事件
	  	$("#search-btn").click(function(){
	  		$('#dataList').datagrid('load',{
	  			username: $('#search_user_username').val(),
	  			name: $('#search_user_name').val()
	  		});
	  	});
	});

	</script>
</head>
<body>
	<!-- 学生列表 -->
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	    
	</table>

	<!-- 工具栏 -->
	<div id="toolbar">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">添加</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>

		<div style="float: left;"><a id="edit" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">修改</a></div>
		<div style="float: left;" class="datagrid-btn-separator"></div>

		<div style="float: left;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">删除</a></div>

		<div style="float: left;margin-top:4px;" class="datagrid-btn-separator" >&nbsp;&nbsp;账号：<input id="search_user_username" class="easyui-textbox" name="search_user_username" /></div>
		<div style="float: left;margin-top:4px;" class="datagrid-btn-separator" >&nbsp;&nbsp;姓名：<input id="search_user_name" class="easyui-textbox" name="search_user_name" /></div>
		<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
	</div>
	
	<!-- 添加学生窗口 -->
	<div id="addDialog" style="padding: 10px">  

    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
				<tr>
					<td>账号:</td>
					<td><input id="add_username" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="username" data-options="required:true, missingMessage:'请填写账号'" /></td>
				</tr>
	    		<tr>
	    			<td>姓名:</td>
	    			<td><input id="add_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name" data-options="required:true, missingMessage:'请填写姓名'" /></td>
	    		</tr>
	    		<tr>
	    			<td>密码:</td>
	    			<td>
	    				<input id="add_password"  class="easyui-textbox" style="width: 200px; height: 30px;" type="password" name="password" data-options="required:true, missingMessage:'请输入登录密码'" />
	    			</td>
	    		</tr>
	    		<tr>
	    			<td>身份:</td>
	    			<td>
						<select id="add_userType" class="easyui-combobox" data-options="editable: false, panelHeight: 100, width: 100, height: 30" name="userType">
							<option value="1">管理员</option>
							<option value="2">学生</option>
							<option value="3">教师</option>
						</select>
					</td>
	    		</tr>
				<tr>
					<td>手机号:</td>
					<td><input id="add_mobile" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="mobile" data-options="required:true, missingMessage:'请填写手机号'" /></td>
				</tr>
	    	</table>
	    </form>
	</div>
	
	<!-- 修改学生窗口 -->
	<div id="editDialog" style="padding: 10px">
    	<form id="editForm" method="post">
			<table cellpadding="8" >
				<tr hidden="true">
					<td>id:</td>
					<td><input id="edit_id" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="id"  hidden="true"/></td>
				</tr>
				<tr>
					<td>账号:</td>
					<td><input id="edit_username" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="username" data-options="required:true, missingMessage:'请填写账号'" /></td>
				</tr>
				<tr>
					<td>姓名:</td>
					<td><input id="edit_name" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="name" data-options="required:true, missingMessage:'请填写姓名'" /></td>
				</tr>
				<tr>
					<td>密码:</td>
					<td>
						<input id="edit_password"  class="easyui-textbox" style="width: 200px; height: 30px;" type="password" name="password" data-options="required:true, missingMessage:'请输入登录密码'" />
					</td>
				</tr>
				<tr>
					<td>身份:</td>
					<td>
						<select id="edit_userType" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="userType">
							<option value="1">管理员</option>
							<option value="2">学生</option>
							<option value="3">教师</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>手机号:</td>
					<td><input id="edit_mobile" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="mobile" data-options="required:true, missingMessage:'请填写手机号'" /></td>
				</tr>
				<tr>
					<td>信誉值:</td>
					<td><input id="edit_reputation" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="reputation" data-options="required:true, missingMessage:'请填写信誉值'" /></td>
				</tr>
			</table>
	    </form>
	</div>

</body>
</html>