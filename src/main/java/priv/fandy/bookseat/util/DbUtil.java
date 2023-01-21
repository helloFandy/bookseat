package priv.fandy.bookseat.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DbUtil {
    private String dbUrl = "jdbc:mysql://localhost:3306/bookseat";
    private String dbUser = "root";
    private String dbPassword = "12345678";
    private String jdbcName = "com.mysql.cj.jdbc.Driver";
    private Connection connection = null;
    //���ݿ����ӷ���
    public Connection getConnection(){
    	try {
			Class.forName(jdbcName);
			connection = DriverManager.getConnection(dbUrl,dbUser,dbPassword);
			System.out.println("----------------���ݿ����ӳɹ�------------------");
		} catch (Exception e) {
			System.out.println("----------------���ݿ�����ʧ��------------------");
			e.printStackTrace();
		}
    	return connection;
    }
    //�ر���Դ����
    public void closeCon(){
    	if(connection != null)
			try {
				connection.close();
				System.out.println("----------------���ݿ����ӹرճɹ�----------------");
			} catch (SQLException e) {
				e.printStackTrace();
			}
    }
	public static void main(String[] args) {
		//���ݿ����Ӳ���
		DbUtil dbUtil = new DbUtil();
		dbUtil.getConnection();
		dbUtil.closeCon();

	}

}
