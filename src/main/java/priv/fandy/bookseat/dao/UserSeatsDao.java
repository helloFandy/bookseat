package priv.fandy.bookseat.dao;

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.user_seat.UserSeatsDO;
import priv.fandy.bookseat.model.user_seat.UserSeatsDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author llq
 *�༶��Ϣ���ݿ����
 */
public class UserSeatsDao extends BaseDao {

	/**
	 * 获取座位列表
	 * @param dto
	 * @param page
	 * @return
	 */
	public List<UserSeatsDTO> getUserSeatsList(UserSeatsDTO dto, Page page){
		List<UserSeatsDTO> ret = new ArrayList<>();
		StringBuffer sql = new StringBuffer("select us.id, us.user_id, us.seat_id, us.start_time, us.end_time, us.status, us.create_date, u.username, u.name, s.rows, s.cols, s.room_id, r.name as room_name ");
		sql.append("from b_user_seats us ");
		sql.append("left join b_user u on us.user_id = u.id ");
		sql.append("left join b_seats s on us.seat_id = s.id ");
		sql.append("left join b_room r on s.room_id = r.id ");
		sql.append("where us.is_deleted = 0 and s.is_deleted = 0 and r.is_deleted = 0 and u.is_deleted = 0 ");

		if(dto.getRoomId() != null){
			sql.append(" and s.room_id = ");
			sql.append(dto.getRoomId());
		}
		if(StringUtils.isNotBlank(dto.getUsername())){
			sql.append(" and u.username = ");
			sql.append(dto.getUsername());
		}
		if(dto.getStatus() != null){
			sql.append(" and us.status = ");
			sql.append(dto.getStatus());
		}
		if(dto.getUserId() != null){
			sql.append(" and us.user_id = ");
			sql.append(dto.getUserId());
		}

		//排序
		sql.append(" order by us.create_date desc ");

		//分页
		sql.append(" limit ");
		sql.append(page.getStart());
		sql.append(",");
		sql.append(page.getPageSize());

		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				UserSeatsDTO userSeatsDTO = new UserSeatsDTO();
				userSeatsDTO.setId(resultSet.getInt("id"));
				userSeatsDTO.setUserId(resultSet.getInt("user_id"));
				userSeatsDTO.setUsername(resultSet.getString("username"));
				userSeatsDTO.setName(resultSet.getString("name"));
				userSeatsDTO.setRoomId(resultSet.getInt("room_id"));
				userSeatsDTO.setRoomName(resultSet.getString("room_name"));
				userSeatsDTO.setSeatId(resultSet.getInt("seat_id"));
				userSeatsDTO.setRows(resultSet.getString("rows"));
				userSeatsDTO.setCols(resultSet.getString("cols"));
				userSeatsDTO.setStartTime(resultSet.getTimestamp("start_time"));
				userSeatsDTO.setEndTime(resultSet.getTimestamp("end_time"));
				userSeatsDTO.setCreateDate(resultSet.getTimestamp("create_date"));
				userSeatsDTO.setStatus(resultSet.getInt("status"));
				ret.add(userSeatsDTO);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 获取座位不分页
	 * @param dto
	 * @return
	 */
	public List<UserSeatsDTO> getUserSeatsVisualizable(UserSeatsDTO dto){
		List<UserSeatsDTO> ret = new ArrayList<>();
		StringBuffer sql = new StringBuffer("SELECT rs.rid,rs.roomName,rs.sid,rs.rows,rs.cols,rs.room_id,us.start_time,us.end_time FROM ");
		sql.append("(SELECT r.id AS rid,r.name AS roomName,s.id AS sid,s.rows,s.cols,s.room_id FROM b_room r ");
		sql.append("LEFT JOIN b_seats s ON r.id = s.room_id ");
		sql.append("WHERE s.is_deleted = 0 AND r.is_deleted = 0 AND r.is_enable = 1 ");
		sql.append("AND  room_id= ");
		sql.append(dto.getRoomId());
		sql.append(") AS rs ");
		sql.append("LEFT JOIN ");
		sql.append("(SELECT seat_id, start_time, end_time FROM b_user_seats ");
		sql.append("WHERE status in (1,2) and start_time <= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" OR start_time <=");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" OR start_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time <= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(") AS us ON rs.sid = us.seat_id");
		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				UserSeatsDTO userSeatsDTO = new UserSeatsDTO();
				userSeatsDTO.setRid(resultSet.getInt("rid"));
				userSeatsDTO.setSid(resultSet.getInt("sid"));
				userSeatsDTO.setRoomName(resultSet.getString("roomName"));
				userSeatsDTO.setRows(resultSet.getString("rows"));
				userSeatsDTO.setCols(resultSet.getString("cols"));
				userSeatsDTO.setRoomId(resultSet.getInt("room_id"));
				userSeatsDTO.setStartTime(resultSet.getDate("start_time"));
				userSeatsDTO.setEndTime(resultSet.getDate("end_time"));
				ret.add(userSeatsDTO);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 座位时间冲突 或者 用户时间冲突
	 * @param dto
	 * @return
	 */
	public List<UserSeatsDTO> getSeatOrUserInterSection(UserSeatsDTO dto){
		List<UserSeatsDTO> ret = new ArrayList<>();
		StringBuffer sql = new StringBuffer("SELECT seat_id, start_time, end_time FROM b_user_seats ");
		sql.append("WHERE status in (1,2) and start_time <= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" OR start_time <=");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" OR start_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time <= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" AND seat_id = ");
		sql.append(dto.getSeatId());

		sql.append(" union all ");

		sql.append("SELECT seat_id, start_time, end_time FROM b_user_seats ");
		sql.append("WHERE status in (1,2) and start_time <= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" OR start_time <=");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" AND end_time >= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" OR start_time >= ");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(" AND end_time <= ");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(" AND user_id = ");
		sql.append(dto.getUserId());

		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				UserSeatsDTO userSeatsDTO = new UserSeatsDTO();
				userSeatsDTO.setRid(resultSet.getInt("rid"));
				userSeatsDTO.setSid(resultSet.getInt("sid"));
				userSeatsDTO.setRoomName(resultSet.getString("roomName"));
				userSeatsDTO.setRows(resultSet.getString("rows"));
				userSeatsDTO.setCols(resultSet.getString("cols"));
				userSeatsDTO.setRoomId(resultSet.getInt("room_id"));
				userSeatsDTO.setStartTime(resultSet.getDate("start_time"));
				userSeatsDTO.setEndTime(resultSet.getDate("end_time"));
				ret.add(userSeatsDTO);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 获取座位条数
	 * @param dto
	 * @return
	 */
	public int getUserSeatsListTotal(UserSeatsDTO dto){
		int total = 0;
		StringBuffer sql = new StringBuffer("select count(*) as total ");
		sql.append("from b_user_seats us ");
		sql.append("left join b_user u on us.user_id = u.id ");
		sql.append("left join b_seats s on us.seat_id = s.id ");
		sql.append("left join b_room r on s.room_id = r.id ");
		sql.append("where us.is_deleted = 0 and s.is_deleted = 0 and r.is_deleted = 0 and u.is_deleted = 0 ");

		if(dto.getRoomId() != null){
			sql.append(" and s.room_id = ");
			sql.append(dto.getRoomId());
		}
		if(StringUtils.isNotBlank(dto.getUsername())){
			sql.append(" and u.username = ");
			sql.append(dto.getUsername());
		}
		if(dto.getStatus() != null){
			sql.append(" and us.status = ");
			sql.append(dto.getStatus());
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
	 * 新增座位
	 * @param dto
	 * @return
	 */
	public boolean addUserSeats(UserSeatsDTO dto){
		StringBuffer sql = new StringBuffer("insert into b_user_seats (user_id,seat_id,start_time,end_time,status) values(");
		sql.append(dto.getUserId());
		sql.append(",");
		sql.append(dto.getSeatId());
		sql.append(",");
		sql.append("'");
		sql.append(dto.getStartDate());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(dto.getEndDate());
		sql.append("'");
		sql.append(",");
		sql.append(dto.getStatus());
		sql.append(")");
		return update(sql.toString());
	}

	/**
	 * 编辑座位
	 * @param usDo
	 * @return
	 */
	public boolean updateStatus(UserSeatsDO usDo) {
		String sql = "update b_user_seats set status = "+usDo.getStatus()+" where id = "+usDo.getId();
		return update(sql);
	}
	
}
