<%@ page import="priv.fandy.bookseat.model.user.UserDO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>座位预定列表</title>
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
	});

	/**
	 * 初始化数据
	 */
	function initData(){
		initTable();

		initSearchRoomSelected();
	}

	/**
	 * 绑定点击事件
	 */
	function bindClickFunction(){

		$("#search-btn").click(function(){
			$('#dataList').datagrid('load',{
				roomId: $('#searchRoom').combobox('getValue'),
				userId: "<%= ((UserDO) session.getAttribute("user")).getId()%>",
				status: $('#searchStatus').combobox('getValue'),
			});
		});
	}

	/**
	 * 初始化表格
	 */
	function initTable(){
		//datagrid初始化
		$('#dataList').datagrid({
			title:'我的选座记录',
			iconCls:'icon-more',//图标
			border: true,
			collapsible: false,//是否可折叠的
			fit: true,//自动大小
			method: "post",
			url:"UserSeatsServlet?oper=getUserSeatsList&t="+new Date().getTime()+"&userId=<%= ((UserDO) session.getAttribute("user")).getId()%>",
			idField:'id',
			//singleSelect: true,//是否单选
			pagination: true,//分页控件
			rownumbers: true,//行号
			remoteSort: false,
			columns: [[
				//{field:'chk',checkbox: true,width:50},
				{field:'id',title:'ID',width:50,hidden: true},
				{field:'userId',title:'userId',width:50,hidden: true},
				{field:'username',title:'账号',width:50},
				{field:'name',title:'姓名',width:50},
				{field:'roomId',title:'自习室id',width:100,hidden:true},
				{field:'roomName',title:'自习室名称',width:100},
				{field:'seatId',title:'seatId',width:50,hidden: true},
				{field:'rows',title:'座位',width:50,hidden: true},
				{field:'cols',title:'座位',width:50,hidden: true},
				{field:'rowsCols',title:'座位',width:150,
					formatter: function(value,row,index){
						return "第"+row.rows+"排第"+row.cols+"列"
					}},
				{field:'startTime',title:'开始时间',width:150},
				{field:'endTime',title:'结束时间',width:150},
				{field:'createDate',title:'预定时间',width:150},
				{field:'status',title:'状态',width:100,
					formatter: function(value,row,index){
						if (value == 1)
							return "待签到";
						if (value == 2)
							return "已签到";
						if (value == 3)
							return "已释放";
						return "undefined";
					}
				},
				{field:'opertion',title:'操作',width:100, align: 'center',
					formatter: function(value,row,index){
						let html = "";
						let curTime = new Date().getTime();
						let startTime = new Date(row.startTime).getTime();
						let endTime = new Date(row.endTime).getTime();
						if (row.status == 1){
							//签到时间要在开始、结束时间之内
							if (curTime >=startTime && curTime <= endTime){
								html += '<a href="#" class="btn-operate" onclick="edit(' + row.id + ',2)" style="margin-right:10px;">签到</a>';
							}
							if (curTime <= endTime){
								html += '<a href="#" class="btn-operate" onclick="edit(' + row.id + ',3)" style="margin-right:10px;">释放</a>'
							}
						}
						if (row.status == 2) {
							if (curTime <= endTime){
								html += '<a href="#" class="btn-operate" onclick="edit(' + row.id + ',3)" style="margin-right:10px;">释放</a>'
							}
						}
						return html;
					}
				},
			]],
			toolbar: "#toolbar"
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
	}

	/**
	 * 初始化自习室搜索框下拉
	 */
	function initSearchRoomSelected(){
		$("#searchRoom").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox",
			editable: true,
			valueField: 'id',
			textField: 'name',
		});
	}

	/**
	 * 编辑操作
	 */
	function edit(id,status){
		let msg = "确认签到?";
		if (status == 3){
			msg = "确认释放?"
		}
		$.messager.confirm("消息提醒", msg, function(r){
			if (r){
				$.ajax({
					type: "post",
					url: "UserSeatsServlet?oper=updateStatus",
					data: {
						id: id,
						status: status
					},
					async: false,
					success: function(data){
						if("success" == data){
							$.messager.alert("消息提醒","操作成功!","info");
							$('#dataList').datagrid("reload");
						}else{
							$.messager.alert("消息提醒",data,"warning");
						}
					}
				});
			}
		});
	}
	</script>
</head>
<body>
	<!-- 数据列表 -->
	<table id="dataList" cellspacing="0" cellpadding="0"></table>

	<!-- 工具栏 -->
	<div id="toolbar" style="border-color: #dddddd;background: #F4F4F4;height: auto;padding: 1px 2px;border-width: 0 0 1px 0;border-style: solid;color: #000000;text-align: left">
		<div style="margin-top: 3px;">
			自习室名称：
			<select id="searchRoom" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
				<option></option>
			</select>
			状态：
			<select id="searchStatus" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="searchStatus">
				<option></option>
				<option value="1">待签到</option>
				<option value="2">已签到</option>
				<option value="3">已释放</option>
			</select>
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
		</div>
	</div>
</body>
</html>