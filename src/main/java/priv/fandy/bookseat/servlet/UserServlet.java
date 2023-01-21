package priv.fandy.bookseat.servlet;

import com.alibaba.fastjson2.JSON;
import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.dao.UserDao;
import priv.fandy.bookseat.enums.UserTypeEnum;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.user.UserDO;
import priv.fandy.bookseat.model.user.UserDTO;
import priv.fandy.bookseat.model.user.UserVO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * 
 *ѧ����Ϣ������ʵ��servlet
 */
public class UserServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = -2303373467552793263L;
	public void doGet(HttpServletRequest request,HttpServletResponse response) throws IOException{
		doPost(request, response);
	}
	public void doPost(HttpServletRequest request,HttpServletResponse response) throws IOException{
		String oper = request.getParameter("oper");
		if("toUserListView".equals(oper)){
			userList(request,response);
		}else if("AddUser".equals(oper)){
			addUser(request,response);
		}else if("UserList".equals(oper)){
			getUserList(request,response);
		}else if("EditUser".equals(oper)){
			editUser(request,response);
		}else if("DeleteUser".equals(oper)){
			deleteUser(request,response);
		}
	}

	/**
	 * 删除用户
	 * @param request
	 * @param response
	 */
	private void deleteUser(HttpServletRequest request,HttpServletResponse response) {

		String[] ids = request.getParameterValues("ids[]");
		String idStr = "";
		for(String id : ids){
			idStr += id + ",";
		}
		idStr = idStr.substring(0, idStr.length()-1);
		UserDao userDao = new UserDao();
		if(userDao.deleteUser(idStr)){
			try {
				response.getWriter().write("success");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}finally{
				userDao.closeCon();
			}
		}
	}

	/**
	 * 编辑用户
	 * @param request
	 * @param response
	 */
	private void editUser(HttpServletRequest request,HttpServletResponse response) {
		UserDO userDO = this.getUserDOFromRequest(request);
		UserDao userDao = new UserDao();
		if(userDao.editUser(userDO)){
			try {
				response.getWriter().write("success");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}finally{
				userDao.closeCon();
			}
		}
	}

	/**
	 * 获取用户列表
	 * @param request
	 * @param response
	 */
	private void getUserList(HttpServletRequest request,HttpServletResponse response) {
		// TODO Auto-generated method stub
		String username = request.getParameter("username");
		String name = request.getParameter("name");
		Integer currentPage = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
		Integer pageSize = request.getParameter("rows") == null ? 999 : Integer.parseInt(request.getParameter("rows"));
		UserDTO user = new UserDTO();
		user.setUsername(username);
		user.setName(name);
		UserDao userDao = new UserDao();
		List<UserDO> users = userDao.getUserList(user, new Page(currentPage, pageSize));
		int total = userDao.getUserListTotal(user);
		userDao.closeCon();
		response.setCharacterEncoding("UTF-8");
		Map<String, Object> ret = new HashMap<String, Object>();
		ret.put("total", total);
		ret.put("rows", users);
		try {
			String from = request.getParameter("from");
			if("combox".equals(from)){
				response.getWriter().write(JSON.toJSONString(users));
			}else{
				response.getWriter().write(JSON.toJSONString(ret));
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * 新增用户
	 * @param request
	 * @param response
	 */
	private void addUser(HttpServletRequest request,HttpServletResponse response) {
		UserDO userDO = this.getUserDOFromRequest(request);
		UserDao userDao = new UserDao();
		if(userDao.addUser(userDO)){
			try {
				response.getWriter().write("success");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}finally{
				userDao.closeCon();
			}
		}
	}

	/**
	 * 网页重定向
	 * @param request
	 * @param response
	 * @throws IOException
	 */
	private void userList(HttpServletRequest request,
			HttpServletResponse response) throws IOException {
		// TODO Auto-generated method stub
		try {
			request.getRequestDispatcher("view/userList.jsp").forward(request, response);
		} catch (ServletException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * list do转vo
	 * @param users
	 * @return
	 */
	private List<UserVO> doToVos(List<UserDO> users){
		List<UserVO> userDOS = new ArrayList<>();

		for (UserDO user : users) {
			if (user != null){
				userDOS.add(this.doToVo(user));
			}
		}
		return userDOS;
	}

	/**
	 * do转vo
	 * @param user
	 * @return
	 */
	private UserVO doToVo(UserDO user){
		if (user == null){
			return null;
		}

		UserVO userVO = new UserVO();
		userVO.setId(user.getId());
		userVO.setName(user.getName());
		userVO.setUserType(Optional.ofNullable(UserTypeEnum.getUserTypeEnumByCode(user.getUserType())).map(e->e.getDesc()).orElse(""));
		userVO.setPassword(user.getPassword());
		userVO.setStatus(user.getStatus());

		return userVO;
	}

	/**
	 * 从request中获取参数构造UserDO
	 * @param request
	 * @return
	 */
	private UserDO getUserDOFromRequest(HttpServletRequest request){
		String username = request.getParameter("username");
		String name = request.getParameter("name");
		String password = request.getParameter("password");
		String mobile = request.getParameter("mobile");
		Integer userType = Integer.valueOf(request.getParameter("userType"));
		Integer reputation = null;
		if (StringUtils.isNotBlank(request.getParameter("reputation"))){
			reputation = Integer.valueOf(request.getParameter("reputation"));
		}
		Integer id = StringUtils.isBlank(request.getParameter("id"))?0:Integer.valueOf(request.getParameter("id"));
		UserDO userDO = new UserDO();
		userDO.setId(id);
		userDO.setStatus(1);
		userDO.setUsername(username);
		userDO.setName(name);
		userDO.setPassword(password);
		userDO.setUserType(userType);
		userDO.setReputation(reputation);
		userDO.setMobile(mobile);
		return userDO;
	}

	/**
	 * 获取用户
	 * @param userDTO
	 */
	public UserDO getOne(UserDTO userDTO) {
		UserDao userDao = new UserDao();
		UserDO user = userDao.getOne(userDTO);
		userDao.closeCon();
		return user;
	}
}
