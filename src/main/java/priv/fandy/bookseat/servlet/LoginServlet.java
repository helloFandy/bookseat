package priv.fandy.bookseat.servlet;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.dao.UserDao;
import priv.fandy.bookseat.model.user.UserDO;
import priv.fandy.bookseat.model.user.UserDTO;

/**
 * 
 *��¼��֤servlet
 */
public class LoginServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -5870852067427524781L;
	
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String oper = request.getParameter("oper");
		if("logout".equals(oper)){
			logout(request, response);
			return;
		}

		UserDO user = null;
		UserDao userDao = new UserDao();
		if ("login".equals(oper)){
			String username = request.getParameter("username");
			String password = request.getParameter("password");
			user = userDao.login(username, password);
			userDao.closeCon();
			if(user == null){
				response.getWriter().write("loginError");
				return;
			}
		}

		if ("register".equals(oper)){
			String username = request.getParameter("username");
			String name = request.getParameter("name");
			String password = request.getParameter("password");
			String mobile = request.getParameter("mobile");
			Integer userType = null;
			if (StringUtils.isNotBlank(request.getParameter("userType"))){
				userType = Integer.parseInt(request.getParameter("userType"));
			}

			UserDTO dto = new UserDTO();
			dto.setUsername(username);
			//判断账号是否存在
			if (userDao.getOne(dto) != null){
				userDao.closeCon();
				response.getWriter().write("账号已存在，请重新换一个账号");
				return;
			}
			UserDO userDO = new UserDO();
			userDO.setName(name);
			userDO.setPassword(password);
			userDO.setUserType(userType);
			userDO.setMobile(mobile);
			userDao.addUser(userDO);
			userDao.closeCon();

			user = userDao.getOne(dto);
		}

		HttpSession session = request.getSession();
		session.setAttribute("user", user);
		session.setAttribute("userType", user.getUserType());
		response.getWriter().write("loginSuccess");
		
	}
	
	private void logout(HttpServletRequest request,HttpServletResponse response) throws IOException{
		request.getSession().removeAttribute("user");
		request.getSession().removeAttribute("userType");
		response.sendRedirect("index.jsp");
	}
}
