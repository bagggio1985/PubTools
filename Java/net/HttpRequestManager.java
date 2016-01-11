

import android.util.Log;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestHandle;
import com.loopj.android.http.RequestParams;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Map;

import cz.msebera.android.httpclient.Header;

public class HttpRequestManager {
    private static AsyncHttpClient mClient = new AsyncHttpClient();
    private static final String BASE_URL = "http://10.0.0.105:9898/";

    public static class ParametersException extends Exception {
        public ParametersException() {
            super();
        }
    }

    public static RequestHandle get(String path, Map<String, String> param, HttpRequestListener listener) throws ParametersException {
        if (path == null || path.length() == 0)
            throw new ParametersException();

        return mClient.get(buildUrl(path), new RequestParams(param), new SimpleJsonHttpResponseHandler(listener) {
            @Override
            protected Object parseJsonObject(JSONObject object) {
                return super.parseJsonObject(object);
            }
        });
    }

    // 普通post方法
    public static RequestHandle post(String path, Map<String, String> param, HttpRequestListener listener) throws ParametersException {
        if (path == null || path.length() == 0)
            throw new ParametersException();

        // multipart/form-data, application/x-www-form-urlencode
        return mClient.post(null, buildUrl(path), null, new RequestParams(param), null, new SimpleJsonHttpResponseHandler(listener) {
            @Override
            protected Object parseJsonObject(JSONObject object) {
                return super.parseJsonObject(object);
            }
        });
    }

    // 上传文件
    public static RequestHandle post(String path, Map<String, String> param, String fileName, String fileUrl, HttpRequestListener listener) throws ParametersException {
        if (path == null || path.length() == 0)
            throw new ParametersException();
        File myFile = new File(fileUrl);
        RequestParams params = new RequestParams(param);
        try {
            params.put(fileName, myFile);
        } catch(FileNotFoundException e) {
            throw new ParametersException();
        }

        return mClient.post(null, buildUrl(path), null, new RequestParams(param), "multipart/form-data", new SimpleJsonHttpResponseHandler(listener) {
            @Override
            protected Object parseJsonObject(JSONObject object) {
                return super.parseJsonObject(object);
            }
        });
    }

    private static String buildUrl(String path) {
        if (path.indexOf(0) == '/') {
            return BASE_URL + path.substring(1);
        }
        else {
            return BASE_URL + path;
        }
    }

    private static class SimpleJsonHttpResponseHandler extends JsonHttpResponseHandler {
        private HttpRequestListener mListener;
        public SimpleJsonHttpResponseHandler(HttpRequestListener listener) {
            super();
            mListener = listener;
        }

        @Override
        public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
            super.onSuccess(statusCode, headers, response);

            CommonException exception = parseError(response);
            if (mListener != null) {
                mListener.onResult(parseJsonObject(response), exception);
            }
        }

        @Override
        public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
            super.onSuccess(statusCode, headers, response);
            if (mListener != null) {
                mListener.onResult(null, new CommonException(CommonException.ERROR_JSON_FORMAT));
            }
        }

        @Override
        public void onSuccess(int statusCode, Header[] headers, String responseString) {
            super.onSuccess(statusCode, headers, responseString);
            if (mListener != null) {
                mListener.onResult(null, new CommonException(CommonException.ERROR_JSON_FORMAT));
            }
        }

        @Override
        public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
            super.onFailure(statusCode, headers, throwable, errorResponse);
            if (mListener != null) {
                mListener.onResult(null, new CommonException(CommonException.ERROR_NETWORK));
            }
        }

        @Override
        public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
            if (mListener != null) {
                mListener.onResult(null, new CommonException(CommonException.ERROR_NETWORK));
            }
        }

        @Override
        public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
            if (mListener != null) {
                mListener.onResult(null, new CommonException(CommonException.ERROR_NETWORK));
            }
        }

        protected Object parseJsonObject(JSONObject object) {
            Log.v("HttpRequestManager", "Object is " + object.toString());
            return object;
        }

        private CommonException parseError(JSONObject object) {
            CommonException exception = null;
            if (object == null) {
                exception = new CommonException(CommonException.ERROR_JSON_FORMAT);
            }
            else {
                try {
                    int code = object.getInt("Code");
                    if (code != 1) {
                        exception = new CommonException(code);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    exception = new CommonException(CommonException.ERROR_JSON_FORMAT);
                }
            }
            return exception;
        }
    }
}
