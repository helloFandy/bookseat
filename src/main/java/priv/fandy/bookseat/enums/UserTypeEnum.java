package priv.fandy.bookseat.enums;

public enum UserTypeEnum {

    ADMIN(1,"管理员"),
    STUDENT(2,"学生"),
    TEACHER(3,"老师");

    private UserTypeEnum(Integer code, String desc){
        this.code = code;
        this.desc = desc;
    }

    private Integer code;
    private String desc;

    public Integer getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    public static UserTypeEnum getUserTypeEnumByCode(Integer code){
        for (UserTypeEnum userType: UserTypeEnum.values()){
            if (code == userType.getCode()) return userType;
        }
        return null;
    }
}
