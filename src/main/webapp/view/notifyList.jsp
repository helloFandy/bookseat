<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>通知公告列表</title>
	<link rel="stylesheet" type="text/css" href="easyui/themes/default/easyui.css">
	<link rel="stylesheet" type="text/css" href="easyui/themes/icon.css">
	<link rel="stylesheet" type="text/css" href="easyui/css/demo.css">
	<script type="text/javascript" src="easyui/jquery.min.js"></script>
	<script type="text/javascript" src="easyui/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="easyui/js/validateExtends.js"></script>
	<script type="text/javascript">
	$(function() {
		//初始化数据
		initData()

		//绑定点击事件
		bindClickFunction();

	  	//设置添加自习室窗口
	    $("#addDialog").dialog({
	    	title: "添加通知",
	    	width: 650,
	    	height: 450,
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
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							$.ajax({
								type: "post",
								url: "NotifyServlet?oper=addNotify",
								data: {
									title: $("#addTitle").val(),
									content: $("#addContent").val(),
								},
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","添加成功!","info");
										//关闭窗口
										$("#addDialog").dialog("close");
										//清空原表格数据
										$("#addTitle").textbox('setValue','');
										$("#addContent").textbox('setValue','');
										//重新刷新页面数据
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("消息提醒",msg,"warning");
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
						$("#addTitle").textbox('setValue','');
						$("#addContent").textbox('setValue','');
					}
				},
			]
	    });
		$("#addDialog").dialog("close");
	  
	  //设置编辑自习室窗口
	    $("#editDialog").dialog({
	    	title: "编辑通知",
	    	width: 650,
	    	height: 450,
	    	iconCls: "icon-add",
	    	modal: true,
	    	collapsible: false,
	    	minimizable: false,
	    	maximizable: false,
	    	draggable: true,
	    	closed: true,
	    	buttons: [
	    		{
					text:'确定修改',
					plain: true,
					iconCls:'icon-add',
					handler:function(){
						var validate = $("#editForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						} else{
							//var gradeid = $("#add_gradeList").combobox("getValue");
							$.ajax({
								type: "post",
								url: "NotifyServlet?oper=editNotify",
								data: {
									id: $("#editId").val(),
									title: $("#editTitle").val(),
									content: $("#editContent").val(),
								},
								success: function(msg){
									if(msg == "success"){
										$.messager.alert("消息提醒","修改成功!","info");
										//关闭窗口
										$("#editDialog").dialog("close");
										//清空原表格数据
										$("#editId").textbox('setValue','');
										$("#editTitle").textbox('setValue','');
										$("#editContent").textbox('setValue','');
										//重新刷新页面数据
							  			$('#dataList').datagrid("reload");
										
									} else{
										$.messager.alert("消息提醒",msg,"warning");
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
						$("#editId").textbox('setValue','');
						$("#editTitle").textbox('setValue','');
						$("#editContent").textbox('setValue','');
					}
				},
			],
			onBeforeOpen: function(){
				let selectRow = $("#dataList").datagrid("getSelected");
				$("#editId").textbox('setValue',selectRow.id);
				$("#editTitle").textbox('setValue',selectRow.title);
				$("#editContent").textbox('setValue',selectRow.content);
				//设置值
			}
	    });
		$("#editDialog").dialog("close")
	  
	});

	/**
	 * 初始化数据
	 */
	function initData(){
		initTable();
	}

	/**
	 * 绑定点击事件
	 */
	function bindClickFunction(){

		$("#search-btn").click(function(){
			$('#dataList').datagrid('load',{
				title: $('#searchTitle').textbox('getValue'),
			});
		});

		//设置工具类按钮
		$("#add").click(function(){
			$("#addDialog").dialog("open");
		});

		//修改按钮监听事件
		$("#edit-btn").click(function(){
			var selectRow = $("#dataList").datagrid("getSelected");
			if(selectRow == null){
				$.messager.alert("消息提醒", "请选择数据进行修改!", "warning");
				return;
			}
			$("#editDialog").dialog("open");
		});

		//删除
		$("#delete").click(function(){
			var selectRow = $("#dataList").datagrid("getSelected");
			//console.log(selectRow);
			if(selectRow == null){
				$.messager.alert("消息提醒", "请选择数据进行删除!", "warning");
			} else{
				var id = selectRow.id;
				$.messager.confirm("消息提醒", "确认删除？", function(r){
					if(r){
						$.ajax({
							type: "post",
							url: "NotifyServlet?oper=deletedNotify",
							data: {id: id},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("消息提醒","删除成功!","info");
									//刷新表格
									$("#dataList").datagrid("reload");
								} else{
									$.messager.alert("消息提醒","删除失败!","warning");
									return;
								}
							}
						});
					}
				});
			}
		});
	}

	/**
	 * 初始化表格
	 */
	function initTable(){
		//datagrid初始化
		$('#dataList').datagrid({
			title:'通知列表',
			iconCls:'icon-more',//图标
			border: true,
			collapsible: false,//是否可折叠的
			fit: true,//自动大小
			method: "post",
			url:"NotifyServlet?oper=getNotifyList&t="+new Date().getTime(),
			idField:'id',
			singleSelect: true,//是否单选
			pagination: true,//分页控件
			rownumbers: true,//行号
			remoteSort: false,
			columns: [[
				{field:'chk',checkbox: true,width:50},
				{field:'id',title:'ID',width:50},
				{field:'title',title:'标题',width:300},
				{field:'content',title:'自习室名称',width:100,hidden:true},
				{field:'createDate',title:'时间',width:150},
				{field:'createBy',title:'创建人',width:100,hidden:true},
				{field:'opertion',title:'操作',width:100, align: 'center',
					formatter: function(value,row,index){
						var html = "";

						html += "<a href='#' class='btn-operate' onclick='showContent(\""+row.content+"\")' style='margin-right:10px;'>查看内容</a>";

						return html;
					}
				},
			]],
			toolbar: "#toolbar"
		});

		//设置分页控件
		let p = $('#dataList').datagrid('getPager');
		$(p).pagination({
			pageSize: 10,//每页显示的记录条数，默认为10
			pageList: [10,20,30,50,100],//可以设置每页记录条数的列表
			beforePageText: '第',//页数文本框前显示的汉字
			afterPageText: '页    共 {pages} 页',
			displayMsg: '当前显示 {from} - {to} 条记录   共 {total} 条记录',
		});
	}

	function showContent(content){
		$('#contentWindow').text(content);
		$('#contentWindow').window({
			width:600,
			height:400,
			modal:true,
			title: '通知内容'
		});
	}
	</script>
</head>
<body>
	<!-- 数据列表 -->
	<table id="dataList" cellspacing="0" cellpadding="0"> 
	</table> 
	
	<!-- 工具栏 -->
	<div id="toolbar">
	<c:if test="${userType == 1 }">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">添加</a></div>
	</c:if>
	<c:if test="${userType == 1 }">
		<div style="float: left; margin-right: 10px;"><a id="edit-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true">修改</a></div>
	</c:if>
	<c:if test="${userType == 1 }">
		<div style="float: left; margin-right: 10px;"><a id="delete" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-some-delete',plain:true">删除</a></div>
	</c:if>
		<div style="margin-top: 3px;">
			标题：
			<input id="searchTitle" class="easyui-textbox" style="width: 100px; height: 30px" data-options="editable: true" name="searchTitle"/>

			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
		</div>
	</div>
	
	<!-- 添加窗口 -->
	<div id="addDialog" style="padding: 10px" class="easyui-dialog" data-options="closed:true">
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>标题:</td>
					<td>
						<input id="addTitle" class="easyui-textbox" style="width: 400px; height: 30px" data-options="editable: true,required:true, missingMessage:'请填写标题'" name="addTitle"/>
					</td>
				</tr>
	    		<tr>
	    			<td>内容:</td>
					<td>
						<input id="addContent" class="easyui-textbox" multiline="true" style="width: 400px; height: 300px" data-options="editable: true,required:true, missingMessage:'请填写内容'" name="addContent"/>
					</td>
	    		</tr>
	    	</table>
	    </form>
	</div>
	
	<!-- 编辑窗口 -->
	<div id="editDialog" style="padding: 10px" class="easyui-dialog" data-options="closed:true">
    	<form id="editForm" method="post">
	    	<table cellpadding="8" >
				<tr hidden="true">
					<td>id:</td>
					<td><input id="editId" style="width: 200px; height: 30px;" class="easyui-textbox" type="text" name="id"  hidden="true"/></td>
				</tr>
				<tr>
					<td>标题:</td>
					<td>
						<input id="editTitle" class="easyui-textbox" style="width: 400px; height: 30px" data-options="editable: true,required:true, missingMessage:'请填写标题'" name="editTitle"/>
					</td>
				</tr>
				<tr>
					<td>内容:</td>
					<td>
						<input id="editContent" class="easyui-textbox" multiline="true" style="width: 400px; height: 300px" data-options="editable: true,required:true, missingMessage:'请填写内容'" name="editContent"/>
					</td>
				</tr>
	    	</table>
	    </form>
	</div>

	<%--	内容弹窗--%>
	<div id="contentWindow"></div>
</body>
</html>