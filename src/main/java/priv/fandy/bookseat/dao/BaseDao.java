package priv.fandy.bookseat.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import priv.fandy.bookseat.util.DbUtil;
//��װӦ�ó���������������ݿ�Ļ�������
public class BaseDao {
	private DbUtil dbUtil = new DbUtil();
	
	//�ر����ݿ����ӣ��ر���Դ
	public void closeCon(){
		dbUtil.closeCon();
	}
    //������ѯ:��������ѯ
	public ResultSet query(String sql){
		try {
			PreparedStatement pstmt = dbUtil.getConnection().prepareStatement(sql);
			return pstmt.executeQuery();
		} catch (SQLException e) {
			
			e.printStackTrace();
		}
		return null;
	}
	//�ı����ݿ����ݲ���
	public boolean update(String sql)
	{
		try {
			return dbUtil.getConnection().prepareStatement(sql).executeUpdate()>0;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}
	public Connection getConnection(){
		return dbUtil.getConnection();
	}
}
