package priv.fandy.bookseat.servlet;

import com.alibaba.fastjson2.JSON;
import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.dao.NotifyDao;
import priv.fandy.bookseat.dao.SeatsDao;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.notify.NotifyDO;
import priv.fandy.bookseat.model.notify.NotifyDTO;
import priv.fandy.bookseat.model.seats.SeatsDO;
import priv.fandy.bookseat.model.seats.SeatsDTO;
import priv.fandy.bookseat.model.user.UserDO;

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
public class NotifyServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String oper = request.getParameter("oper");
		if("toNotifyListView".equals(oper)){
			notifyList(request,response);
		}else{
			String data = "";
			if("getNotifyList".equals(oper)){
				data = getNotifyList(request);
			}else if("addNotify".equals(oper)){
				data = addNotify(request);
			}else if("deletedNotify".equals(oper)){
				data = deleteNotify(request);
			}else if("editNotify".equals(oper)){
				data = editNotify(request);
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
	 */
	private String editNotify(HttpServletRequest request) {

		if (StringUtils.isBlank(request.getParameter("id"))){
			return "id不能为空";
		}

		NotifyDO notifyDO = this.getNotifyDOFromRequest(request);

		NotifyDao notifyDao = new NotifyDao();
		try{
			notifyDao.editNotify(notifyDO);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "更新失败，请稍后重试";
		}finally {
			notifyDao.closeCon();
		}

	}

	/**
	 * 删除座位
	 * @param request
	 */
	private String deleteNotify(HttpServletRequest request) {
		if (StringUtils.isBlank(request.getParameter("id"))){
			return "id不能为空";
		}

		NotifyDao notifyDao = new NotifyDao();
		try {
			Integer id = Integer.parseInt(request.getParameter("id"));
			notifyDao.deleteNotify(id);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "删除失败，请稍后重新";
		}finally {
			notifyDao.closeCon();
		}

	}

	/**
	 * 新增通知
	 * @param request
	 */
	private String addNotify(HttpServletRequest request) {
		NotifyDO notifyDO = this.getNotifyDOFromRequest(request);
		NotifyDao dao = new NotifyDao();

		try{
			dao.addNotify(notifyDO);
			return "success";
		}catch (Exception e){
			e.printStackTrace();
			return "新增座位失败，请稍后重试";
		}finally {
			dao.closeCon();
		}
	}

	/**
	 * 页面重定向
	 * @param request
	 * @param response
	 */
	private void notifyList(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			request.getRequestDispatcher("view/notifyList.jsp").forward(request, response);
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
	private String getNotifyList(HttpServletRequest request){
		String title = request.getParameter("title");

		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		NotifyDTO dto = new NotifyDTO();
		dto.setTitle(title);
		NotifyDao dao = new NotifyDao();
		List<NotifyDO> seatsList = dao.getNotifyList(dto, new Page(currentPage, pageSize));
		int total = dao.getNotifyListTotal(dto);
		dao.closeCon();
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
	 * 从参数中构造do
	 * @param request
	 * @return
	 */
	private NotifyDO getNotifyDOFromRequest(HttpServletRequest request){
		Integer id = null;
		if (StringUtils.isNotBlank(request.getParameter("id"))){
			id = Integer.valueOf(request.getParameter("id"));
		}
		String title = request.getParameter("title");
		String content = request.getParameter("content");

		NotifyDO notifyDO = new NotifyDO();
		notifyDO.setId(id);
		notifyDO.setTitle(title);
		notifyDO.setContent(content);
		notifyDO.setCreateBy(((UserDO) request.getSession().getAttribute("user")).getUsername());
		return notifyDO;
	}
}
