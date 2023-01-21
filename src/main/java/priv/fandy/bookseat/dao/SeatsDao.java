package priv.fandy.bookseat.dao;

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.seats.SeatsDO;
import priv.fandy.bookseat.model.seats.SeatsDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author llq
 *�༶��Ϣ���ݿ����
 */
public class SeatsDao extends BaseDao {

	/**
	 * 获取座位列表
	 * @param seatsDTO
	 * @param page
	 * @return
	 */
	public List<SeatsDTO> getSeatsList(SeatsDTO seatsDTO, Page page){
		List<SeatsDTO> ret = new ArrayList<>();
		StringBuffer sql = new StringBuffer("select s.id, s.room_id, s.rows, s.cols, s.is_deleted, r.name as roomName, r.is_deleted as rdeleted from b_seats s inner join b_room r on s.room_id = r.id");
		sql.append(" where s.is_deleted = 0 and r.is_deleted = 0 and r.is_enable = 1 ");

		if(seatsDTO.getRoomId() != null){
			sql.append(" and room_id = ");
			sql.append(seatsDTO.getRoomId());
		}

		//排序
		sql.append(" order by s.room_id,s.rows,s.cols ");

		sql.append(" limit ");
		sql.append(page.getStart());
		sql.append(",");
		sql.append(page.getPageSize());
		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				SeatsDTO Seats = new SeatsDTO();
				Seats.setId(resultSet.getInt("id"));
				Seats.setRoomName(resultSet.getString("roomName"));
				Seats.setRows(resultSet.getString("rows"));
				Seats.setCols(resultSet.getString("cols"));
				Seats.setRoomId(resultSet.getInt("room_id"));
				ret.add(Seats);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * 获取座位
	 * @param seatsDTO
	 * @return
	 */
	public SeatsDTO getOne(SeatsDTO seatsDTO){
		StringBuffer sql = new StringBuffer("select s.id, s.room_id, s.rows, s.cols, s.is_deleted, r.name as roomName, r.is_deleted as rdeleted from b_seats s inner join b_room r on s.room_id = r.id");
		sql.append(" where s.is_deleted = 0 and r.is_deleted = 0 and r.is_enable = 1");

		if(seatsDTO.getRoomId() != null){
			sql.append(" and s.room_id = ");
			sql.append(seatsDTO.getRoomId());
		}
		if(StringUtils.isNotBlank(seatsDTO.getRows())){
			sql.append(" and s.rows = ");
			sql.append("'");
			sql.append(seatsDTO.getRows());
			sql.append("'");
		}
		if(StringUtils.isNotBlank(seatsDTO.getCols())){
			sql.append(" and s.cols = ");
			sql.append("'");
			sql.append(seatsDTO.getCols());
			sql.append("'");
		}

		sql.append(" limit 0,1 ");
		ResultSet resultSet = query(sql.toString());
		try {
			if(resultSet!= null && resultSet.next()){
				SeatsDTO dto = new SeatsDTO();
				dto.setId(resultSet.getInt("id"));
				dto.setRoomName(resultSet.getString("roomName"));
				dto.setRows(resultSet.getString("rows"));
				dto.setCols(resultSet.getString("cols"));
				dto.setRoomId(resultSet.getInt("room_id"));
				dto.setIsDeleted(resultSet.getInt("rdeleted"));
				return dto;
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 获取座位条数
	 * @param seatsDTO
	 * @return
	 */
	public int getSeatsListTotal(SeatsDTO seatsDTO){
		int total = 0;
		StringBuffer sql = new StringBuffer("select count(*) as total from b_seats s inner join b_room r on s.room_id = r.id where s.is_deleted = 0 and r.is_enable = 1 and r.is_deleted = 0 ");

		if(seatsDTO.getRoomId() != null){
			sql.append(" and room_id = ");
			sql.append(seatsDTO.getRoomId());
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
	 * @param seatsDO
	 * @return
	 */
	public boolean addSeats(SeatsDO seatsDO){
		StringBuffer sql = new StringBuffer("insert into b_seats (`rows`,cols,room_id) values(");
		sql.append("'");
		sql.append(seatsDO.getRows());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(seatsDO.getCols());
		sql.append("'");
		sql.append(",");
		sql.append(seatsDO.getRoomId());
		sql.append(")");
		return update(sql.toString());
	}

	/**
	 * 删除座位
	 * @param id
	 * @return
	 */
	public boolean deleteSeats(int id){
		StringBuffer sql = new StringBuffer("delete from b_seats where id = ");
		sql.append(id);
		return update(sql.toString());
	}

	/**
	 * 编辑座位
	 * @param seatsDO
	 * @return
	 */
	public boolean editSeats(SeatsDO seatsDO) {
		StringBuffer sql = new StringBuffer("update b_seats set ");
		sql.append(" `rows` = ");
		sql.append("'");
		sql.append(seatsDO.getRows());
		sql.append("'");
		sql.append(",");
		sql.append(" cols = ");
		sql.append("'");
		sql.append(seatsDO.getCols());
		sql.append("'");
		sql.append(",");
		sql.append(" room_id = ");
		sql.append(seatsDO.getRoomId());
		sql.append(" where id = ");
		sql.append(seatsDO.getId());
		return update(sql.toString());
	}
	
}
