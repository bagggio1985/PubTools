

public class CommonException extends Exception {

    public static final int ERROR_DEFAULT = 0;
    public static final int ERROR_NETWORK = -1;
    public static final int ERROR_JSON_FORMAT = -2;

    private int mCode = ERROR_DEFAULT;

    public int getCode() {
        return mCode;
    }

    public CommonException(int code) {
        super();
        mCode = code;
    }

    public CommonException(int code, String detailMessage) {
        super(detailMessage);
        mCode = code;
    }

    public CommonException(int code, String detailMessage, Throwable throwable) {
        super(detailMessage, throwable);
        mCode = code;
    }
}
