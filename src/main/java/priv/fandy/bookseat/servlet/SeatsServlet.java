package priv.fandy.bookseat.servlet;

import com.alibaba.fastjson2.JSON;
import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.dao.SeatsDao;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.seats.SeatsDO;
import priv.fandy.bookseat.model.seats.SeatsDTO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLSyntaxErrorException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 *�༶��Ϣ����servlet
 */
public class SeatsServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String oper = request.getParameter("oper");
		if("toSeatsListView".equals(oper)){
			seatsList(request,response);
		}else{
			String data = "";
			if("getSeatsList".equals(oper)){
				data = getSeatsList(request);
			}else if("AddSeats".equals(oper)){
				data = addSeats(request);
			}else if("DeleteSeats".equals(oper)){
				data = deleteSeats(request, response);
			}else if("EditSeats".equals(oper)){
				data = editSeats(request, response);
			}

			try {
				response.setCharacterEncoding("UTF-8");
				response.getWriter().write(data);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * 编辑座位
	 * @param request
	 * @param response
	 */
	private String editSeats(HttpServletRequest request,
			HttpServletResponse response) {

		if (StringUtils.isBlank(request.getParameter("id"))){
			return "id不能为空";
		}

		SeatsDO seatsDO = this.getSeatsDOFromRequest(request);
		SeatsDTO dto = this.getOne(null,seatsDO.getRows(),seatsDO.getCols(),seatsDO.getRoomId());
		if (dto != null && dto.getId() != seatsDO.getId()){
			return "座位已存在，请重新编辑";
		}

		SeatsDao seatsDao = new SeatsDao();
		try{
			seatsDao.editSeats(seatsDO);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "更新失败，请稍后重试";
		}finally {
			seatsDao.closeCon();
		}

	}

	/**
	 * 删除座位
	 * @param request
	 * @param response
	 */
	private String deleteSeats(HttpServletRequest request,
			HttpServletResponse response) {
		if (StringUtils.isBlank(request.getParameter("id"))){
			return "id不能为空";
		}

		SeatsDao seatsDao = new SeatsDao();
		try {
			Integer id = Integer.parseInt(request.getParameter("id"));
			seatsDao.deleteSeats(id);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "删除失败，请稍后重新";
		}finally {
			seatsDao.closeCon();
		}

	}

	/**
	 * 新增座位
	 * @param request
	 */
	private String addSeats(HttpServletRequest request) {
		SeatsDO seatsDO = this.getSeatsDOFromRequest(request);
		SeatsDTO dto = this.getOne(seatsDO.getId(),seatsDO.getRows(),seatsDO.getCols(),seatsDO.getRoomId());
		SeatsDao seatsDao = new SeatsDao();
		if (dto != null){
			return "座位已存在,请添加别的座位";
		}

		try{
			seatsDao.addSeats(seatsDO);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "新增座位失败，请稍后重试";
		}finally {
			seatsDao.closeCon();
		}
	}

	/**
	 * 页面重定向
	 * @param request
	 * @param response
	 */
	private void seatsList(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			request.getRequestDispatcher("view/seatsList.jsp").forward(request, response);
		} catch (ServletException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 获取座位列表
	 * @param request
	 */
	private String getSeatsList(HttpServletRequest request){
		Integer roomId = null;
		String cols = request.getParameter("cols");

		String rows = request.getParameter("rows");

		if (StringUtils.isNotBlank(request.getParameter("roomId"))){
			roomId = Integer.valueOf(request.getParameter("roomId"));
		}

		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		SeatsDTO seatsDTO = new SeatsDTO();
		seatsDTO.setCols(cols);
		seatsDTO.setRows(rows);
		seatsDTO.setRoomId(roomId);
		SeatsDao seatsDao = new SeatsDao();
		List<SeatsDTO> seatsList = seatsDao.getSeatsList(seatsDTO, new Page(currentPage, pageSize));
		int total = seatsDao.getSeatsListTotal(seatsDTO);
		seatsDao.closeCon();
		Map<String, Object> ret = new HashMap<String, Object>();
		ret.put("total", total);
		ret.put("rows", seatsList);

		String from = request.getParameter("from");
		if("combox".equals(from)){
			return JSON.toJSONString(seatsList);
		}else{
			return JSON.toJSONString(ret);
		}

	}

	/**
	 * 获取座位
	 */
	private SeatsDTO getOne(Integer id, String rows, String cols, Integer roomId){
		SeatsDTO dto = null;
		SeatsDTO seatsDTO = new SeatsDTO();
		seatsDTO.setId(id);
		seatsDTO.setCols(cols);
		seatsDTO.setRows(rows);
		seatsDTO.setRoomId(roomId);
		SeatsDao seatsDao = new SeatsDao();
		try{
			dto = seatsDao.getOne(seatsDTO);
		}catch (Exception e){
			e.printStackTrace();
		}finally {
			seatsDao.closeCon();
		}
		return dto;
	}

	/**
	 * 从参数中构造do
	 * @param request
	 * @return
	 */
	private SeatsDO getSeatsDOFromRequest(HttpServletRequest request){
		Integer id = StringUtils.isBlank(request.getParameter("id"))?0:Integer.valueOf(request.getParameter("id"));
		String name = request.getParameter("name");
		String rows = request.getParameter("rows");
		String cols = request.getParameter("cols");
		Integer roomId = StringUtils.isBlank(request.getParameter("roomId"))?null:Integer.valueOf(request.getParameter("roomId"));
		SeatsDO seats = new SeatsDO();
		seats.setId(id);
		seats.setName(name);
		seats.setRows(rows);
		seats.setCols(cols);
		seats.setRoomId(roomId);
		return seats;
	}
}
