package priv.fandy.bookseat.dao;
/**
 * ����Ա���ݷ�װ
 * @author CesareBorgia
 */

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.user.UserDO;
import priv.fandy.bookseat.model.user.UserDTO;
import priv.fandy.bookseat.util.StringUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDao extends BaseDao{

	/**
	 * 登录
	 * @param username
	 * @param password
	 * @return
	 */
    public UserDO login(String username, String password){
    	String sql = "select * from b_user where username = '" + username + "' and password = '" + password + "' and is_deleted = 0";
    	ResultSet ret = query(sql);
    	try {
			if(ret.next()){
				UserDO userDO = new UserDO();
				userDO.setId(ret.getInt("id"));
				userDO.setName(ret.getString("name"));
				userDO.setPassword(ret.getString("password"));
				userDO.setStatus(ret.getInt("status"));
				userDO.setUserType(ret.getInt("user_type"));
				userDO.setMobile(ret.getString("mobile"));
				userDO.setReputation(ret.getInt("reputation"));
				return userDO;
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return null;
    }

	/**
	 * 编辑密码
	 * @param userDO
	 * @param newPassword
	 * @return
	 */
    public boolean editPassword(UserDO userDO,String newPassword){
    	String sql = "update b_user set password = '"+newPassword+"' where id = " + userDO.getId()+" and is_deleted = 0";
    	return update(sql);
    }

	/**
	 * 删除用户
	 * @param userDO
	 * @return
	 */
	public boolean addUser(UserDO userDO){
		StringBuffer sql = new StringBuffer("insert into b_user (name,password,status,user_type,username,mobile) values(");
		sql.append("'");
		sql.append(userDO.getName());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(userDO.getPassword());
		sql.append("'");
		sql.append(",");
		sql.append(userDO.getStatus());
		sql.append(",");
		sql.append(userDO.getUserType());
		sql.append(",");
		sql.append("'");
		sql.append(userDO.getUsername());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(userDO.getMobile());
		sql.append("'");
		sql.append(")");
		return update(sql.toString());
	}

	/**
	 * 编辑用户
	 * @param userDO
	 * @return
	 */
	public boolean editUser(UserDO userDO) {
		StringBuffer sql = new StringBuffer("update b_user set name = ");
		sql.append("'");
		sql.append(userDO.getName());
		sql.append("'");
		sql.append(",");
		sql.append("password = ");
		sql.append("'");
		sql.append(userDO.getPassword());
		sql.append("'");
		sql.append(",");
		sql.append("status = ");
		sql.append(userDO.getStatus());
		sql.append(",");
		sql.append("user_type = ");
		sql.append(userDO.getUserType());
		sql.append(",");
		sql.append("username = ");
		sql.append("'");
		sql.append(userDO.getUsername());
		sql.append("'");
		sql.append(",");
		sql.append("mobile = ");
		sql.append("'");
		sql.append(userDO.getMobile());
		sql.append("'");
		sql.append(",");
		sql.append("reputation = ");
		sql.append(userDO.getReputation());
		sql.append(" where id = ");
		sql.append(userDO.getId());
		return update(sql.toString());
	}

	/**
	 * 删除用户
	 * @param id
	 * @return
	 */
	public boolean deleteUser(String id) {
		String sql = "update b_user set is_deleted = 1 where id in("+id+")";
		return update(sql);
	}

	/**
	 * 根据id获取用户
	 * @param dto
	 * @return
	 */
	public UserDO getOne(UserDTO dto){
		StringBuffer sql = new StringBuffer("select * from b_user where is_deleted = 0 ");
		if (dto.getId() != null){
			sql.append("and id = ");
			sql.append(dto.getId());
		}
		if (dto.getUsername() != null){
			sql.append("and username = ");
			sql.append("'");
			sql.append(dto.getId());
			sql.append("'");
		}
		sql.append(" limit 0,1 ");

		UserDO userDO = null;
		ResultSet resultSet = query(sql.toString());
		try {
			if(resultSet.next()){
				userDO = new UserDO();
				userDO.setId(resultSet.getInt("id"));
				userDO.setUsername(resultSet.getString("username"));
				userDO.setName(resultSet.getString("name"));
				userDO.setPassword(resultSet.getString("password"));
				userDO.setUserType(resultSet.getInt("user_type"));
				userDO.setStatus(resultSet.getInt("status"));
				return userDO;
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return userDO;
	}

	/**
	 * 获取用户列表
	 * @param userDTO
	 * @param page
	 * @return
	 */
	public List<UserDO> getUserList(UserDTO userDTO, Page page){
		List<UserDO> ret = new ArrayList<>();
		String sql = "select * from b_user where is_deleted = 0";
		if(StringUtils.isNotBlank(userDTO.getName())){
			sql += " and name like '%" + userDTO.getName() + "%'";
		}
		if(StringUtils.isNotBlank(userDTO.getUsername())){
			sql += " and username like '%" + userDTO.getUsername() + "%'";
		}
		if(userDTO.getId() != null){
			sql += " and id = " + userDTO.getId();
		}
		sql += " limit " + page.getStart() + "," + page.getPageSize();
		ResultSet resultSet = query(sql);
		try {
			while(resultSet.next()){
				UserDO userDO = new UserDO();
				userDO.setId(resultSet.getInt("id"));
				userDO.setUserType(resultSet.getInt("user_type"));
				userDO.setUsername(resultSet.getString("username"));
				userDO.setName(resultSet.getString("name"));
				userDO.setPassword(resultSet.getString("password"));
				userDO.setStatus(resultSet.getInt("status"));
				userDO.setMobile(resultSet.getString("mobile"));
				userDO.setReputation(resultSet.getInt("reputation"));
				ret.add(userDO);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 获取用户条数
	 * @param userDTO
	 * @return
	 */
	public int getUserListTotal(UserDTO userDTO){
		int total = 0;
		String sql = "select count(*)as total from b_user where is_deleted = 0";
		if(StringUtils.isNotBlank(userDTO.getName())){
			sql += " and name like '%" + userDTO.getName() + "%'";
		}
		if(StringUtils.isNotBlank(userDTO.getUsername())){
			sql += " and username like '%" + userDTO.getUsername() + "%'";
		}
		if(userDTO.getId() != null){
			sql += " and id = " + userDTO.getId();
		}
		ResultSet resultSet = query(sql);
		try {
			while(resultSet.next()){
				total = resultSet.getInt("total");
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return total;
	}
}
