package priv.fandy.bookseat.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.room.RoomDO;
import priv.fandy.bookseat.model.room.RoomDTO;
import priv.fandy.bookseat.util.StringUtil;

/**
 * 
 * @author llq
 *�༶��Ϣ���ݿ����
 */
public class RoomDao extends BaseDao {

	/**
	 * 获取自习室列表
	 * @param roomDTO
	 * @param page
	 * @return
	 */
	public List<RoomDO> getRoomList(RoomDTO roomDTO, Page page){
		List<RoomDO> ret = new ArrayList<RoomDO>();
		StringBuffer sql = new StringBuffer("select * from b_room where is_deleted = 0 ");
		if(!StringUtil.isEmpty(roomDTO.getName())){
			sql.append(" and name like '%");
			sql.append(roomDTO.getName());
			sql.append("%'");
		}
		if(roomDTO.getIsEnable() != null){
			sql.append(" and is_enable = ");
			sql.append(roomDTO.getIsEnable());
		}
		if(roomDTO.getId() != null){
			sql.append(" and id = ");
			sql.append(roomDTO.getId());
		}
		sql.append(" limit ");
		sql.append(page.getStart());
		sql.append(",");
		sql.append(page.getPageSize());
		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				RoomDO room = new RoomDO();
				room.setId(resultSet.getInt("id"));
				room.setName(resultSet.getString("name"));
				room.setLocation(resultSet.getString("location"));
				room.setIsEnable(StringUtils.isNotBlank(resultSet.getString("is_enable"))?Integer.valueOf(resultSet.getString("is_enable")):0);
				room.setRows(resultSet.getString("rows"));
				room.setCols(resultSet.getString("cols"));
				ret.add(room);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 获取自习室条数
	 * @param roomDTO
	 * @return
	 */
	public int getRoomListTotal(RoomDTO roomDTO){
		int total = 0;
		StringBuffer sql = new StringBuffer("select count(*) as total from b_room where is_deleted = 0 ");
		if(!StringUtil.isEmpty(roomDTO.getName())){
			sql.append(" and name like '%");
			sql.append(roomDTO.getName());
			sql.append("%'");
		}
		if(roomDTO.getIsEnable() != null){
			sql.append(" and is_enable = ");
			sql.append(roomDTO.getIsEnable());
		}
		if(roomDTO.getId() != null){
			sql.append(" and id = ");
			sql.append(roomDTO.getId());
		}
		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				total = resultSet.getInt("total");
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return total;
	}

	/**
	 * 新增自习室
	 * @param roomDO
	 * @return
	 */
	public boolean addRoom(RoomDO roomDO){
		StringBuffer sql = new StringBuffer("insert into b_room (name,location,`rows`,cols,is_enable) values(");
		sql.append("'");
		sql.append(roomDO.getName());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(roomDO.getLocation());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(roomDO.getRows());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(roomDO.getCols());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(roomDO.getIsEnable());
		sql.append("'");
		sql.append(")");
		return update(sql.toString());
	}

	/**
	 * 删除自习室
	 * @param id
	 * @return
	 */
	public boolean deleteRoom(int id){
		//String sql = "delete from b_room where is_deleted = 0 and id = "+id;
		StringBuffer sql = new StringBuffer("update b_room set is_deleted = 1 where id = ");
		sql.append(id);
		return update(sql.toString());
	}

	/**
	 * 编辑自习室
	 * @param roomDO
	 * @return
	 */
	public boolean editRoom(RoomDO roomDO) {
		StringBuffer sql = new StringBuffer("update b_room set name = ");
		sql.append("'");
		sql.append(roomDO.getName());
		sql.append("'");
		sql.append(",");
		sql.append(" location = ");
		sql.append("'");
		sql.append(roomDO.getLocation());
		sql.append("'");
		sql.append(",");
		sql.append(" `rows` = ");
		sql.append("'");
		sql.append(roomDO.getRows());
		sql.append("'");
		sql.append(",");
		sql.append(" cols = ");
		sql.append("'");
		sql.append(roomDO.getCols());
		sql.append("'");
		sql.append(",");
		sql.append(" is_enable = ");
		sql.append(roomDO.getIsEnable());
		sql.append(" where id = ");
		sql.append(roomDO.getId());
		return update(sql.toString());
	}
	
}
