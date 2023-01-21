package priv.fandy.bookseat.dao;

import org.apache.commons.lang3.StringUtils;
import priv.fandy.bookseat.model.Page;
import priv.fandy.bookseat.model.notify.NotifyDO;
import priv.fandy.bookseat.model.notify.NotifyDTO;
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
public class NotifyDao extends BaseDao {

	/**
	 * 获取座位列表
	 * @param dto
	 * @param page
	 * @return
	 */
	public List<NotifyDO> getNotifyList(NotifyDTO dto, Page page){
		List<NotifyDO> ret = new ArrayList<>();
		StringBuffer sql = new StringBuffer("select * from b_notify where is_deleted = 0 ");

		if(dto.getTitle() != null){
			sql.append(" and title like '%");
			sql.append(dto.getTitle());
			sql.append("%'");
		}

		//排序
		sql.append(" order by create_date desc ");

		sql.append(" limit ");
		sql.append(page.getStart());
		sql.append(",");
		sql.append(page.getPageSize());
		ResultSet resultSet = query(sql.toString());
		try {
			while(resultSet.next()){
				NotifyDO notifyDO = new NotifyDO();
				notifyDO.setId(resultSet.getInt("id"));
				notifyDO.setTitle(resultSet.getString("title"));
				notifyDO.setContent(resultSet.getString("content"));
				notifyDO.setCreateDate(resultSet.getTimestamp("create_date"));
				notifyDO.setCreateBy(resultSet.getString("create_by"));
				notifyDO.setIsDeleted(resultSet.getInt("is_deleted"));
				ret.add(notifyDO);
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
			sql.append(seatsDTO.getRoomId());
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
	 * @param dto
	 * @return
	 */
	public int getNotifyListTotal(NotifyDTO dto){
		int total = 0;
		StringBuffer sql = new StringBuffer("select count(*) as total from b_notify where is_deleted = 0 ");

		if(dto.getTitle() != null){
			sql.append(" and title like '%");
			sql.append(dto.getTitle());
			sql.append("%'");
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
	 * @param notifyDO
	 * @return
	 */
	public boolean addNotify(NotifyDO notifyDO){
		StringBuffer sql = new StringBuffer("insert into b_notify (title,content,create_by) values(");
		sql.append("'");
		sql.append(notifyDO.getTitle());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(notifyDO.getContent());
		sql.append("'");
		sql.append(",");
		sql.append("'");
		sql.append(notifyDO.getCreateBy());
		sql.append("'");
		sql.append(")");
		return update(sql.toString());
	}

	/**
	 * 删除座位
	 * @param id
	 * @return
	 */
	public boolean deleteNotify(Integer id){
		StringBuffer sql = new StringBuffer("delete from b_notify where id = ");
		sql.append(id);
		return update(sql.toString());
	}

	/**
	 * 编辑座位
	 * @param notifyDO
	 * @return
	 */
	public boolean editNotify(NotifyDO notifyDO) {
		StringBuffer sql = new StringBuffer("update b_notify set ");
		sql.append(" title = ");
		sql.append("'");
		sql.append(notifyDO.getTitle());
		sql.append("'");
		sql.append(",");
		sql.append(" content = ");
		sql.append("'");
		sql.append(notifyDO.getContent());
		sql.append("'");
		sql.append(" where id = ");
		sql.append(notifyDO.getId());
		return update(sql.toString());
	}
	
}
