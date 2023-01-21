package priv.fandy.bookseat.servlet;

import com.alibaba.fastjson2.JSON;
import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.dao.RoomDao;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.room.RoomDO;
import priv.fandy.bookseat.model.room.RoomDTO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 *�༶��Ϣ����servlet
 */
public class RoomServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String method = request.getParameter("oper");
		if("toRoomListView".equals(method)){
			roomList(request,response);
		}else if("getRoomList".equals(method)){
			getRoomList(request, response);
		}else if("AddRoom".equals(method)){
			addRoom(request, response);
		}else if("DeleteRoom".equals(method)){
			deleteRoom(request, response);
		}else if("EditRoom".equals(method)){
			editRoom(request, response);
		}
	}

	/**
	 * 编辑自习室
	 * @param request
	 * @param response
	 */
	private void editRoom(HttpServletRequest request,
			HttpServletResponse response) {

		String msg = "";
		RoomDao roomDao = new RoomDao();

		if (StringUtils.isBlank(request.getParameter("id"))){
			msg = "id不能为空";
		}else{
			RoomDO roomDO = this.getRoomDOFromRequest(request);
			roomDao.editRoom(roomDO);
			msg = "success";
		}

		try {
			response.getWriter().write(msg);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			roomDao.closeCon();
		}
	}

	/**
	 * 删除自习室
	 * @param request
	 * @param response
	 */
	private void deleteRoom(HttpServletRequest request,
			HttpServletResponse response) {
		String msg = "";
		RoomDao roomDao = new RoomDao();

		if (StringUtils.isBlank(request.getParameter("id"))){
			msg = "id不能为空";
		}else {
			Integer id = Integer.parseInt(request.getParameter("id"));
			roomDao.deleteRoom(id);
			msg = "success";
		}
		try {
			response.getWriter().write(msg);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			roomDao.closeCon();
		}
	}

	/**
	 * 新增自习室
	 * @param request
	 * @param response
	 */
	private void addRoom(HttpServletRequest request,
			HttpServletResponse response) {
		RoomDO roomDO = this.getRoomDOFromRequest(request);
		RoomDao roomDao = new RoomDao();
		if(roomDao.addRoom(roomDO)){
			try {
				response.getWriter().write("success");
			} catch (IOException e) {
				e.printStackTrace();
			}finally{
				roomDao.closeCon();
			}
		}
		
	}

	/**
	 * 页面重定向
	 * @param request
	 * @param response
	 */
	private void roomList(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			request.getRequestDispatcher("view/roomList.jsp").forward(request, response);
		} catch (ServletException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 获取自习室列表
	 * @param request
	 * @param response
	 */
	private void getRoomList(HttpServletRequest request,HttpServletResponse response){
		String name = request.getParameter("name");
		Integer id = null;
		Integer isEnable = null;
		if (StringUtils.isNotBlank(request.getParameter("isEnable"))){
			isEnable = Integer.valueOf(request.getParameter("isEnable"));
		}
		if (StringUtils.isNotBlank(request.getParameter("id"))){
			id = Integer.valueOf(request.getParameter("id"));
		}

		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		RoomDTO roomDTO = new RoomDTO();
		roomDTO.setId(id);
		roomDTO.setName(name);
		roomDTO.setIsEnable(isEnable);
		RoomDao roomDao = new RoomDao();
		List<RoomDO> roomList = roomDao.getRoomList(roomDTO, new Page(currentPage, pageSize));
		int total = roomDao.getRoomListTotal(roomDTO);
		roomDao.closeCon();
		response.setCharacterEncoding("UTF-8");
		Map<String, Object> ret = new HashMap<String, Object>();
		ret.put("total", total);
		ret.put("rows", roomList);
		try {
			String from = request.getParameter("from");
			if("combox".equals(from)){
				response.getWriter().write(JSON.toJSONString(roomList));
			}else{
				response.getWriter().write(JSON.toJSONString(ret));
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 从参数中构造do
	 * @param request
	 * @return
	 */
	private RoomDO getRoomDOFromRequest(HttpServletRequest request){
		Integer id = StringUtils.isBlank(request.getParameter("id"))?0:Integer.valueOf(request.getParameter("id"));
		String name = request.getParameter("name");
		String location = request.getParameter("location");
		String rows = request.getParameter("rows");
		String cols = request.getParameter("cols");

		Integer isEnable = 0;
		if (StringUtils.isNotBlank(request.getParameter("isEnable"))){
			isEnable = Integer.valueOf(request.getParameter("isEnable"));
		}
		RoomDO room = new RoomDO();
		room.setId(id);
		room.setName(name);
		room.setLocation(location);
		room.setIsEnable(isEnable);
		room.setRows(rows);
		room.setCols(cols);
		return room;
	}
}
