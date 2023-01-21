package priv.fandy.bookseat.servlet;

import com.alibaba.fastjson2.JSON;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import priv.fandy.bookseat.dao.UserSeatsDao;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.user.UserDO;
import priv.fandy.bookseat.model.user_seat.UserSeatsDO;
import priv.fandy.bookseat.model.user_seat.UserSeatsDTO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 
 *�༶��Ϣ����servlet
 */
public class UserSeatsServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String oper = request.getParameter("oper");
		List<String> redirectToViews = Arrays.asList("toUserSeatsVisibleView","toUserSeatsListView","toMySeatsListView");
		if (redirectToViews.contains(oper)){
			toViews(request,response);
		}

		String data = "";
		if("getUserSeatsList".equals(oper)){
			data = getUserSeatsList(request);
		}else if("getUserSeatsVisualizable".equals(oper)){
			data = getUserSeatsVisualizable(request);
		} else if("AddUserSeats".equals(oper)){
			data = addUserSeats(request);
		}else if("updateStatus".equals(oper)){
			data = updateStatus(request);
		}else if("DeleteUserSeats".equals(oper)){
			//data = deleteUserSeats(request, response);
		} else if("EditUserSeats".equals(oper)){
			//data = editUserSeats(request, response);
		}

		try {
			response.setCharacterEncoding("UTF-8");
			response.getWriter().write(data);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 编辑座位
	 * @param request
	 * @param response
	 */
//	private String editUserSeats(HttpServletRequest request,
//			HttpServletResponse response) {
//
//		if (StringUtils.isBlank(request.getParameter("id"))){
//			return "id不能为空";
//		}
//
//		UserSeatsDO UserSeatsDO = this.getUserSeatsDOFromRequest(request);
//		UserSeatsDTO dto = this.getOne(null,UserSeatsDO.getRows(),UserSeatsDO.getCols(),UserSeatsDO.getRoomId());
//		if (dto != null && dto.getId() != UserSeatsDO.getId()){
//			return "座位已存在，请重新编辑";
//		}
//
//		UserSeatsDao UserSeatsDao = new UserSeatsDao();
//		try{
//			UserSeatsDao.editUserSeats(UserSeatsDO);
//			return "success";
//		}catch (Exception e){
//			e.printStackTrace();
//			return "更新失败，请稍后重试";
//		}finally {
//			UserSeatsDao.closeCon();
//		}
//
//	}

	/**
	 * 更新状态
	 * @param request
	 */
	private String updateStatus(HttpServletRequest request) {

		if (StringUtils.isBlank(request.getParameter("id"))){
			return "id不能为空";
		}
		if (request.getParameter("status") == null){
			return "状态不能为空";
		}

		UserSeatsDO usDo = new UserSeatsDO();
		usDo.setId(Integer.parseInt(request.getParameter("id")));
		usDo.setStatus(Integer.parseInt(request.getParameter("status")));

		UserSeatsDao userSeatsDao = new UserSeatsDao();
		try{
			userSeatsDao.updateStatus(usDo);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "更新失败，请稍后重试";
		}finally {
			userSeatsDao.closeCon();
		}

	}

	/**
	 * 删除座位
	 * @param request
	 * @param response
	 */
//	private String deleteUserSeats(HttpServletRequest request,
//			HttpServletResponse response) {
//		if (StringUtils.isBlank(request.getParameter("id"))){
//			return "id不能为空";
//		}
//
//		UserSeatsDao UserSeatsDao = new UserSeatsDao();
//		try {
//			Integer id = Integer.parseInt(request.getParameter("id"));
//			UserSeatsDao.deleteUserSeats(id);
//			return "success";
//		}catch (Exception e){
//			e.printStackTrace();
//			return "删除失败，请稍后重新";
//		}finally {
//			UserSeatsDao.closeCon();
//		}
//
//	}

	/**
	 * 新增座位
	 * @param request
	 */
	private String addUserSeats(HttpServletRequest request) {

		//获取参数并校验
		UserDO user = (UserDO)request.getSession().getAttribute("user");
		Integer userId = user.getId();
		Integer reputation = user.getReputation();
		Integer seatId = StringUtils.isBlank(request.getParameter("seatId"))?null:Integer.valueOf(request.getParameter("seatId"));
		String startTime = request.getParameter("startTime");
		String endTime = request.getParameter("endTime");
		if (seatId == null){
			return "座位不能为空";
		}
		if (StringUtils.isBlank(startTime)){
			return "开始时间不能为空";
		}
		if (StringUtils.isBlank(endTime)){
			return "结束时间不能为空";
		}
		if (reputation < 60){
			return "您的信誉值低于60，不能选座";
		}

		UserSeatsDTO dto = new UserSeatsDTO();
		dto.setUserId(userId);
		dto.setSeatId(seatId);
		dto.setStartDate(startTime);
		dto.setEndDate(endTime);
		dto.setStatus(1);

		UserSeatsDao userSeatsDao = new UserSeatsDao();

		//判断座位时间是否冲突 或者 用户时间是否冲突
		List<UserSeatsDTO> userSeatsDTOS = userSeatsDao.getSeatOrUserInterSection(dto);
		if (CollectionUtils.isNotEmpty(userSeatsDTOS)){
			userSeatsDao.closeCon();
			return "时间冲突,请确认";
		}

		try{
			userSeatsDao.addUserSeats(dto);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "新增座位失败，请稍后重试";
		}finally {
			userSeatsDao.closeCon();
		}
	}

	/**
	 * 页面重定向
	 * @param request
	 * @param response
	 */
	private void toViews(HttpServletRequest request,
							   HttpServletResponse response) {

		Map<String,String> viewMap = Maps.newHashMap();
		viewMap.put("toUserSeatsVisibleView","view/userSeats.jsp");
		viewMap.put("toUserSeatsListView","view/userSeatsList.jsp");
		viewMap.put("toMySeatsListView","view/mySeatsList.jsp");

		String oper = request.getParameter("oper");

		try {
			request.getRequestDispatcher(viewMap.get(oper)).forward(request, response);
		} catch (ServletException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 座位预定情况可视化
	 * @param request
	 */
	private String getUserSeatsVisualizable(HttpServletRequest request){
		//获取参数
		Integer roomId = null;
		if (StringUtils.isNotBlank(request.getParameter("roomId"))){
			roomId = Integer.valueOf(request.getParameter("roomId"));
		}
		String startTime = request.getParameter("startTime");
		String endTime = request.getParameter("endTime");

		//校验
		if (roomId == null){
			return "自习室不能为空";
		}
		if (StringUtils.isBlank(startTime)){
			return "开始时间不能为空";
		}
		if (StringUtils.isBlank(endTime)){
			return "结束时间不能为空";
		}
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date startDate = null;
		Date endDate = null;
		Date curDate = new Date();
		try {
			startDate = format.parse(startTime);
			endDate = format.parse(endTime);
		} catch (ParseException e) {
			return "时间格式转换错误";
		}
		if (startDate.after(endDate)){
			return "开始时间不能比结束时间晚";
		}
		if (curDate.after(startDate)){
			return "开始时间不能比当前时间早";
		}

		UserSeatsDTO userSeatsDTO = new UserSeatsDTO();
		userSeatsDTO.setRoomId(roomId);
		userSeatsDTO.setStartDate(startTime);
		userSeatsDTO.setEndDate(endTime);

		UserSeatsDao UserSeatsDao = new UserSeatsDao();
		List<UserSeatsDTO> UserSeatsList = UserSeatsDao.getUserSeatsVisualizable(userSeatsDTO);
		UserSeatsDao.closeCon();

		return JSON.toJSONString(UserSeatsList);

	}

	/**
	 * 获取座位列表
	 * @param request
	 */
	private String getUserSeatsList(HttpServletRequest request){
		//获取参数
		Integer roomId = null;
		if (StringUtils.isNotBlank(request.getParameter("roomId"))){
			roomId = Integer.valueOf(request.getParameter("roomId"));
		}
		Integer userId = null;
		if (StringUtils.isNotBlank(request.getParameter("userId"))){
			userId = Integer.valueOf(request.getParameter("userId"));
		}
		Integer status = null;
		if (StringUtils.isNotBlank(request.getParameter("status"))){
			status = Integer.valueOf(request.getParameter("status"));
		}
		String username = request.getParameter("username");

		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		UserSeatsDTO dto = new UserSeatsDTO();
		dto.setRoomId(roomId);
		dto.setUserId(userId);
		dto.setUsername(username);
		dto.setStatus(status);
		UserSeatsDao dao = new UserSeatsDao();
		List<UserSeatsDTO> UserSeatsList = dao.getUserSeatsList(dto, new Page(currentPage, pageSize));
		int total = dao.getUserSeatsListTotal(dto);
		dao.closeCon();
		Map<String, Object> ret = new HashMap<>();
		ret.put("total", total);
		ret.put("rows", UserSeatsList);

		String from = request.getParameter("from");
		if("combox".equals(from)){
			return JSON.toJSONString(UserSeatsList);
		}else{
			return JSON.toJSONString(ret);
		}

	}

	/**
	 * 获取座位
	 */
//	private UserSeatsDTO getOne(Integer id, String rows, String cols, Integer roomId){
//		UserSeatsDTO dto = null;
//		UserSeatsDTO UserSeatsDTO = new UserSeatsDTO();
//		UserSeatsDTO.setId(id);
//		UserSeatsDTO.setCols(cols);
//		UserSeatsDTO.setRows(rows);
//		UserSeatsDTO.setRoomId(roomId);
//		UserSeatsDao UserSeatsDao = new UserSeatsDao();
//		try{
//			dto = UserSeatsDao.getOne(UserSeatsDTO);
//		}catch (Exception e){
//			e.printStackTrace();
//		}finally {
//			UserSeatsDao.closeCon();
//		}
//		return dto;
//	}

}
