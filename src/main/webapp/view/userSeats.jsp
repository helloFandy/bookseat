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

		//新增dialog
		$("#addDialog").dialog({
			title: "预定座位",
			width: 600,
			height: 400,
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
						let validate = $("#addForm").form("validate");
						if(!validate){
							$.messager.alert("消息提醒","请检查你输入的数据!","warning");
							return;
						}

						//时间验证
						let curDate = new Date();
						let startTime = $("#addStartTime").textbox('getValue');
						let endTime = $("#addEndTime").textbox('getValue');
						let startDate = new Date(startTime);
						let endDate = new Date(endTime);
						if(curDate.getTime() > startDate.getTime()){
							$.messager.alert("消息提醒","开始时间不能早于当前时间!","warning");
							return;
						}
						if(endDate.getTime() < startDate.getTime()){
							$.messager.alert("消息提醒","结束时间不能早于开始时间!","warning");
							return;
						}

						$.ajax({
							type: "post",
							url: "UserSeatsServlet?oper=AddUserSeats",
							data: {
								seatId: $("#addRowsCols").combobox('getValue'),
								startTime: startTime,
								endTime: endTime
							},
							success: function(msg){
								if(msg == "success"){
									$.messager.alert("消息提醒","添加成功!","info");
									//关闭窗口
									$("#addDialog").dialog("close");
									//重新加载
									$("#addRoom").combobox('setValue','');
									$("#addRowsCols").combobox('clear');
									$("#addStartTime").textbox('setValue','');
									$("#addEndTime").textbox('setValue','');
									//初始化页面表格
									let data = $("#searchRoom").combobox("getData");
									initTable(data[0].rows,data[0].cols);
									getUserSeatsVisualizable();

								} else{
									$.messager.alert("消息提醒",msg,"warning");
									return;
								}
							}
						});
					}
				},
				{
					text:'重置',
					plain: true,
					iconCls:'icon-reload',
					handler:function(){
						//重置数据
						$("#addRoom").combobox('setValue','');
						$("#addRowsCols").combobox('clear');
						$("#addStartTime").textbox('setValue','');
						$("#addEndTime").textbox('setValue','');
					}
				},
			]
		});
		$("#addDialog").dialog("close");
	});

	/**
	 * 初始化数据
	 */
	function initData(){
		initSearchRoomSelected();

		initSearchTimeInput();

		initAddRoomSelected();

		initAddTimeInput();
	}

	/**
	 * 绑定点击事件
	 */
	function bindClickFunction(){

		$("#add").click(function (){
			$("#addDialog").dialog("open");
		});

		$("#search-btn").click(function (){
			//获取rows和cols
			let rows = 0;
			let cols = 0;
			let data = $("#searchRoom").combobox('getData');
			let id = $("#searchRoom").combobox('getValue');
			for (let i = 0; i < data.length; i++) {
				if (data[i].id == id){
					rows = data[i].rows;
					cols = data[i].cols;
					break;
				}
			}

			//初始化表格
			initTable(rows,cols);

			//获取数据
			getUserSeatsVisualizable();
		});
	}

	/**
	 * 初始化自习室搜索框下拉
	 */
	function initSearchRoomSelected(){
		$("#searchRoom").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox&isEnable=1",
			editable: true,
			valueField: 'id',
			textField: 'name',
			onLoadSuccess: function(){
				let data = $(this).combobox("getData");
				$(this).combobox("setValue", data[0].id);

				//初始化页面表格
				initTable(data[0].rows,data[0].cols);
				getUserSeatsVisualizable();
			}
		});
	}

	/**
	 * 初始化自习室搜索框下拉
	 */
	function initAddRoomSelected(){
		$("#addRoom").combobox({
			url: "RoomServlet?oper=getRoomList&t="+new Date().getTime()+"&from=combox",
			editable: true,
			valueField: 'id',
			textField: 'name',
			onLoadSuccess: function(){},
			onSelect: function(rec) {//当选中combobox中的内容时候触发的事件 类似与change事件 参数rec 为当前选中项目的json 类型的数据  json中的键和值 应与  valueField和textField属性中的值一致 如 rec.id 为当前选中项的 id
				let datas = [];
				let seatDatas = [];
				$.ajax({
					type: "post",
					url: "SeatsServlet?oper=getSeatsList&from=combox",
					data: {roomId: rec.id},
					async: false,
					success: function(data){
						const dataObj = eval("("+data+")");
						datas = dataObj;
					}
				});

				//初始化排数据
				$('#addRowsCols').combobox({
					textField:'name',
					valueField:'val',
					width:90
				});
				for (let i = 0; i < datas.length; i++) {
					const rowData = {
						"name": '第'+datas[i].rows+'排第'+datas[i].cols+'列',
						"val": datas[i].id
					};
					seatDatas.push(rowData);
				}
				$('#addRowsCols').combobox('clear').combobox('loadData',seatDatas);
			}
		});
	}

	/**
	 * 初始化时间输入框
	 */
	function initSearchTimeInput(){
		let curTime = new Date();
		let startTime=new Date(curTime.getTime()+3600000);
		let endTime=new Date(curTime.getTime()+3600000*2);
		$("#searchStartTime").textbox("setValue",dateInitialize(startTime));
		$("#searchEndTime").textbox("setValue",dateInitialize(endTime));
	}

	/**
	 * 初始化预定自习室时间输入框
	 */
	function initAddTimeInput(){
		let curTime = new Date();
		let startTime=new Date(curTime.getTime()+3600000);
		let endTime=new Date(curTime.getTime()+3600000*2);
		$("#addStartTime").textbox("setValue",dateInitialize(startTime));
		$("#addEndTime").textbox("setValue",dateInitialize(endTime));
	}

	/**
	 * 点击搜索按钮
	 */
	function searchClick(){

		//获取rows和cols
		let rows = 0;
		let cols = 0;
		let data = $("#searchRoom").combobox('getData');
		let id = $("#searchRoom").combobox('getValue');
		for (let i = 0; i < data.length; i++) {
			if (data[i].id == id){
				rows = data[i].rows;
				cols = data[i].cols;
				break;
			}
		}

		//初始化表格
		initTable(rows,cols);

		//获取数据
		getUserSeatsVisualizable();
	}

	/**
	 * 时间格式化
	 * @param value
	 * @returns {string}
	 */
	function dateInitialize (date) {
		var year = date.getFullYear().toString();
		var month = (date.getMonth() + 1);
		var day = date.getDate().toString();
		var hour = date.getHours().toString();
		if (month < 10) {
			month = "0" + month;
		}
		if (day < 10) {
			day = "0" + day;
		}
		if (hour < 10) {
			hour = "0" + hour;
		}
		return year + "-" + month + "-" + day + " " + hour+":00:00";
	}

	/**
	 * 获取预定座位数据
	 */
	function getUserSeatsVisualizable(){
		$.ajax({
			type: "post",
			url: "UserSeatsServlet?oper=getUserSeatsVisualizable",
			data: {
				roomId: $("#searchRoom").combobox("getValue"),
				startTime: $("#searchStartTime").textbox("getValue"),
				endTime: $("#searchEndTime").textbox("getValue")
			},
			success: function(msg){
				try{
					let emptyImg = '<img src="${pageContext.request.contextPath}/h-ui/images/seat.png" style="height: 40px;width: 40px">';
					let busyImg = '<img src="${pageContext.request.contextPath}/h-ui/images/seated.png" style="height: 40px;width: 40px">';
					let data = eval("("+msg+")");
					for (let i = 0; i < data.length; i++) {
						let rowsIndex = data[i].rows-1;
						let colsIndx = data[i].cols-1;
						if(data[i].startTime == null  || data[i].endTime == null || data[i].status == 3){
							$("#seats"+rowsIndex.toString()+colsIndx.toString()).append(emptyImg);
						}else{
							$("#seats"+rowsIndex.toString()+colsIndx.toString()).append(busyImg);
						}

					}
				}catch (err){
					console.log(err);
					$.messager.alert("消息提醒",msg,"warning");
				}
			}
		});
	}

	/**
	 * 初始化表格
	 */
	function initTable(rows, cols){
		//先移除再拼接
		$("#visibleSeat").empty()

		let html = getTableHtml(rows,cols);
		$("#visibleSeat").append(html);
	}

	/**
	 * 获取表格
	 */
	function getTableHtml(rows, cols){
		let html = '<table width=100%';
		for (let i=0; i<rows; i++){
			html+='<tr>';
			for (let j=0; j<cols; j++){
				html += '<td id=seats'+i.toString()+j.toString()+'></td>';
			}
			html += '</tr>';
		}
		html += '</table>';
		return html;
	}
	</script>

	<style>
		#visibleSeat table{
			padding: 10%;
			border-spacing: 20px;
			text-align: center;
			border:1px solid green;
		}
		#visibleSeat td{
			width: 40px;
			height: 40px;
		}
	</style>
</head>
<body>
	
	<!-- 工具栏 -->
	<div id="toolbar" style="border-color: #dddddd;background: #F4F4F4;height: auto;padding: 1px 2px;border-width: 0 0 1px 0;border-style: solid;color: #000000;text-align: left;margin-top: -20px;">
		<div style="float: left;"><a id="add" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true">预定</a></div>
		<div style="margin-top: 3px;">
			自习室名称：
			<select id="searchRoom" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
				<option></option>
			</select>
			开始时间：<input id="searchStartTime" class="easyui-textbox" style="width: 150" placehold="yyyy-MM-dd HH:mm:ss">
			结束时间：<input id="searchEndTime" class="easyui-textbox" style="width: 150" placehold="yyyy-MM-dd HH:mm:ss">
			<a id="search-btn" href="javascript:;" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true">搜索</a>
		</div>
	</div>

	<div id="visibleSeat" style="height:100%;width:100%">

	<!-- 添加窗口 -->
	<div id="addDialog" style="padding: 10px" class="easyui-dialog" data-options="closed:true">
    	<form id="addForm" method="post">
	    	<table cellpadding="8" >
	    		<tr>
	    			<td>自习室:</td>
					<td>
						<select id="addRoom" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="roomId">
							<option></option>
						</select>
					</td>
				</tr>
	    		<tr>
	    			<td>座位:</td>
					<td>
						<select id="addRowsCols" class="easyui-combobox" data-options="editable: true, panelHeight: 100, width: 100, height: 30" name="rows">
							<option></option>
						</select>
					</td>
				</tr>
				<tr>
					<td>开始时间:</td>
					<td><input id="addStartTime" style="width: 150px; height: 30px;" class="easyui-textbox" type="text" data-options="required:true, missingMessage:'请填写开始时间'" /></td>
					<td>结束时间:</td>
					<td><input id="addEndTime" style="width: 150px;height: 30px;" class="easyui-textbox" type="text" data-options="required:true, missingMessage:'请填写结束时间'" /></td>
				</tr>

	    	</table>
	    </form>
	</div>
	</div>
</body>
</html>