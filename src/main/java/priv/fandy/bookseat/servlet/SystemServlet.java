package priv.fandy.bookseat.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import priv.fandy.bookseat.dao.UserDao;
import priv.fandy.bookseat.model.user.UserDO;

/**
 * 系统servlet
 * @author CesareBorgia
 *
 */
public class SystemServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
  
    public SystemServlet() {
        super();
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String oper = request.getParameter("oper");
		if("toPersonalView".equals(oper)){
			personalView(request, response);
			return;
		}else if("EditPasswod".equals(oper)){
			editPassword(request, response);
			return;
		}
		request.getRequestDispatcher("view/system.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	private void editPassword(HttpServletRequest request,HttpServletResponse response){
        //设置编码
		response.setCharacterEncoding("UTF-8");

		//获取参数
		String password = request.getParameter("password");
		String newPassword = request.getParameter("newpassword");

		//获取当前登录用户密码与输入密码进行校验
		UserDO userDO = (UserDO)request.getSession().getAttribute("user");
		if(!userDO.getPassword().equals(password)){
			try {
				response.getWriter().write("您所输入的密码不正确，请重新输入");
				return;
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		//更新密码
		UserDao userDao = new UserDao();
		if(userDao.editPassword(userDO,newPassword)){
			try {
				response.getWriter().write("success");
			} catch (IOException e) {
				e.printStackTrace();
			}
			finally{
				userDao.closeCon();
			}
		}else{
			try {
				response.getWriter().write("更新密码失败");
			} catch (IOException e) {
				e.printStackTrace();
			}finally {
				userDao.closeCon();
			}
		}
		
	}
	
	private void personalView(HttpServletRequest request,HttpServletResponse response){
		try {
			request.getRequestDispatcher("view/personalView.jsp").forward(request, response);
		} catch (ServletException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
