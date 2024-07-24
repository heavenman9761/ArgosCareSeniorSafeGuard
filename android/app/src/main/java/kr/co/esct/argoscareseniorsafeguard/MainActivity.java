package kr.co.esct.argoscareseniorsafeguard;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.wifi.WifiManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.espressif.provisioning.DeviceConnectionEvent;
import com.espressif.provisioning.ESPConstants;
import com.espressif.provisioning.ESPProvisionManager;
import com.espressif.provisioning.WiFiAccessPoint;
import com.espressif.provisioning.listeners.BleScanListener;
import com.espressif.provisioning.listeners.ProvisionListener;
import com.espressif.provisioning.listeners.ResponseListener;
import com.espressif.provisioning.listeners.WiFiScanListener;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "mings";
    private static final String CHANNEL = "est.co.kr/IoT_Hub";
    private static final int REQUEST_LOCATION = 1;
    private static final int REQUEST_ENABLE_BT = 2;

    private static final int REQUEST_FINE_LOCATION = 3;
    private static final long DEVICE_CONNECT_TIMEOUT = 20000;
    private ESPProvisionManager provisionManager;
    private SharedPreferences sharedPreferences;
    private String deviceType;
    private BluetoothAdapter bleAdapter;
    private String deviceNamePrefix;
    private boolean isDeviceConnected = false, isConnecting = false;
    private boolean isScanning = false;
    private Handler handler;
    private ArrayList<BleDevice> deviceList;
    private ArrayList<String> deviceNameList;
    private HashMap<BluetoothDevice, String> bluetoothDevices;

    private MethodChannel.Result mainActivityResult;

    private String hubName = "";
    private String hubID = "";
    private String accountID = "";
    private String serverIp = "";
    private String serverPort = "";
    private String userID = "";
    private String userPw = "";
    private String selectedWifiName = "";
    private String selectedWifiPassword = "";
    private ArrayList<WiFiAccessPoint> wifiAPList;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        EventBus.getDefault().register(this);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread.
                            if (call.method.equals("findEsp32")) {
                                hubName = "";
                                mainActivityResult = result;
                                scanEsp32Device();
                            } else if (call.method.equals("settingHub")) {
                                hubName = call.argument("hubName");
                                hubID = "";
                                accountID = call.argument("accountID");
                                serverIp = call.argument("serverIp");
                                serverPort = call.argument("serverPort");
                                userID = call.argument("userID");
                                userPw = call.argument("userPw");

                                mainActivityResult = result;

                                settingHub();
                            } else if (call.method.equals("_wifiProvision")) {
                                wifiAPList = new ArrayList<>();
                                mainActivityResult = result;

                                startWifiScan();
                            } else if (call.method.equals("setWifiConfig")) {
                                selectedWifiName = call.argument("wifiName");
                                selectedWifiPassword = call.argument("password");
//                                Log.d(TAG, "-------------- " + selectedWifiName + "  " + selectedWifiPassword);

                                mainActivityResult = result;

                                startWifiProvision();
                            } else if (call.method.equals("stopByUser")) {
                                mainActivityResult = result;

                                closeErrorActivity("Stop by User");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void startWifiProvision() {
        provisionManager.getEspDevice().provision(selectedWifiName, selectedWifiPassword, new ProvisionListener() {

            @Override
            public void createSessionFailed(Exception e) {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG,"Failed to create session");
                    }
                });
            }

            @Override
            public void wifiConfigSent() {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG,"Wi-Fi config sent.");
                    }
                });
            }

            @Override
            public void wifiConfigFailed(Exception e) {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG,"Failed to send Wi-Fi credentials");
                    }
                });
            }

            @Override
            public void wifiConfigApplied() {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG,"Wi-Fi config applied.");
                    }
                });
            }

            @Override
            public void wifiConfigApplyFailed(Exception e) {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG,"Failed to apply Wi-Fi credentials");
                    }
                });
            }

            @Override
            public void provisioningFailedFromDevice(final ESPConstants.ProvisionFailureReason failureReason) {

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        switch (failureReason) {
                            case AUTH_FAILED:
                                Log.d(TAG,"Wi-Fi Authentication failed.");
                                closeErrorActivity("Wi-Fi Authentication failed.");
                                break;
                            case NETWORK_NOT_FOUND:
                                Log.d(TAG,"Network not found.");
                                closeErrorActivity("Network not found.");
                                break;
                            case DEVICE_DISCONNECTED:
                            case UNKNOWN:
                                Log.d(TAG, "Failed to provisioning device");
                                closeErrorActivity("Failed to provisioning device");
                                break;
                        }
                    }
                });
            }

            @Override
            public void deviceProvisioningSuccess() {
                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG, "Device provisioning success.");
                        mainActivityResult.success("Device provisioning success.");
                    }
                });
            }

            @Override
            public void onProvisioningFailed(Exception e) {

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        Log.d(TAG, "Failed to provisioning device");
                        closeErrorActivity("Failed to provisioning device");
                    }
                });
            }
        });
    }

    private void scanEsp32Device() {
        sharedPreferences = getSharedPreferences(AppConstants.ESP_PREFERENCES, Context.MODE_PRIVATE);
        provisionManager = ESPProvisionManager.getInstance(getApplicationContext());

        WifiManager wifi = (WifiManager)getSystemService(Context.WIFI_SERVICE);
        if (wifi.isWifiEnabled()){
            if (VERSION.SDK_INT >= VERSION_CODES.P) {

                if (!isLocationEnabled()) {
                    askForLocation();
                    closeErrorActivity("Can't find device");
                }
            }

            final BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
            BluetoothAdapter bleAdapter = bluetoothManager.getAdapter();

            if (!bleAdapter.isEnabled()) {
                Log.d("mings", "Bluetooth is disabled.");
                closeErrorActivity("Bluetooth is disabled.");
            } else {
                startProvisioningFlow();
            }
        } else {
            Log.d("mings", "Wifi manager is disabled.");
            closeErrorActivity("Wifi manager is disabled.");
        }
    }

    private void startProvisioningFlow() {
        deviceType = AppConstants.DEVICE_TYPE_BLE;
        final boolean isSec1 = sharedPreferences.getBoolean(AppConstants.KEY_SECURITY_TYPE, true);
        Log.d(TAG, "Device Types : " + deviceType);
        Log.d(TAG, "isSec1 : " + isSec1);
        int securityType = 0;
        if (isSec1) {
            //여기
            securityType = 1;
        }

        provisionManager.createESPDevice(ESPConstants.TransportType.TRANSPORT_BLE, ESPConstants.SecurityType.SECURITY_1);
        bleProvisionLanding(securityType);
    }

    private void bleProvisionLanding(int securityType) {
        Log.d(TAG, "bleProvisionLanding()");
        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            closeErrorActivity("Sorry! BLE is not supported - 1");
            return;
        }

        final BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        bleAdapter = bluetoothManager.getAdapter();

        // Checks if Bluetooth is supported on the device.
        if (bleAdapter == null) {
            closeErrorActivity("Sorry! BLE is not supported - 2");
            return;
        }

        isConnecting = false;
        isDeviceConnected = false;
        handler = new Handler();
        bluetoothDevices = new HashMap<>();
        deviceList = new ArrayList<>();
        deviceNameList = new ArrayList<>();
        deviceNamePrefix = sharedPreferences.getString(AppConstants.KEY_BLE_DEVICE_NAME_PREFIX, "PROV_");

        if (!bleAdapter.isEnabled()) {

        } else {

            if (!isDeviceConnected && !isConnecting) {
                startScan();
            }
        }
    }

    private void startScan() {
        isScanning = true;
        deviceList.clear();
        bluetoothDevices.clear();

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            provisionManager.searchBleEspDevices(deviceNamePrefix, bleScanListener);
        } else {
            closeErrorActivity("Not able to start scan as Location permission is not granted.");
        }
    }

    private void stopScan() {

        isScanning = false;

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            provisionManager.stopBleScan();
        } else {
            closeErrorActivity("Not able to stop scan as Location permission is not granted.");
        }

        if (deviceList.size() <= 0) {
            closeErrorActivity("No Bluetooth devices found!");
        }
    }

    private BleScanListener bleScanListener = new BleScanListener() {

        @Override
        public void scanStartFailed() {
            isScanning = false;
            closeErrorActivity("Please turn on Bluetooth to connect BLE device");
        }

        @Override
        public void onPeripheralFound(BluetoothDevice device, ScanResult scanResult) {
//            Log.d(TAG, "====== onPeripheralFound ===== " + device.getName());
            boolean deviceExists = false;
            String serviceUuid = "";

            if (scanResult.getScanRecord().getServiceUuids() != null && scanResult.getScanRecord().getServiceUuids().size() > 0) {
                serviceUuid = scanResult.getScanRecord().getServiceUuids().get(0).toString();
            }
//            Log.d(TAG, "Add service UUID : " + serviceUuid);

            if (bluetoothDevices.containsKey(device)) {
                deviceExists = true;
            }

            if (!deviceExists) {
                BleDevice bleDevice = new BleDevice();
                bleDevice.setName(scanResult.getScanRecord().getDeviceName());
                bleDevice.setBluetoothDevice(device);

                bluetoothDevices.put(device, serviceUuid);
                deviceList.add(bleDevice);

                deviceNameList.add(scanResult.getScanRecord().getDeviceName());

                stopScan();
            }
        }

        @Override
        public void scanCompleted() {
            isScanning = false;

            Log.d(TAG, "scanCompleted() - " + deviceNameList.toString());

//            EventBus.getDefault().unregister(this);
            mainActivityResult.success(deviceNameList);
        }

        @Override
        public void onFailure(Exception e) {
            Log.e(TAG, e.getMessage());
            e.printStackTrace();
        }
    };

    private void settingHub() {
        BleDevice bleDevice = deviceList.get(0);
        String uuid = bluetoothDevices.get(bleDevice.getBluetoothDevice());

        provisionManager.getEspDevice().connectBLEDevice(bleDevice.getBluetoothDevice(), uuid);
        handler.postDelayed(disconnectDeviceTask, DEVICE_CONNECT_TIMEOUT);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(DeviceConnectionEvent event) {

        handler.removeCallbacks(disconnectDeviceTask);

        switch (event.getEventType()) {

            case ESPConstants.EVENT_DEVICE_CONNECTED:
                Log.d(TAG, "Device Connected Event Received");
                isConnecting = false;
                isDeviceConnected = true;

                //isSecure: false && securityType != AppConstants.SEC_TYPE_0을 전제로 한다.
                //isSecure, securityType의 용도는 모르겠음.
                processDeviceCapabilities();

                break;

            case ESPConstants.EVENT_DEVICE_DISCONNECTED:
                Log.d(TAG, "Device Disconnected Event");
                isConnecting = false;
                isDeviceConnected = false;
                //Toast.makeText(BLEProvisionLanding.this, "Device disconnected", Toast.LENGTH_LONG).show();
                break;

            case ESPConstants.EVENT_DEVICE_CONNECTION_FAILED:
                Log.d(TAG, "Device Connection Failed Event");
                isConnecting = false;
                isDeviceConnected = false;
                //Utils.displayDeviceConnectionError(this, getString(R.string.error_device_connect_failed));
                break;
        }
    }

    private void processDeviceCapabilities() {
        ArrayList<String> deviceCaps = provisionManager.getEspDevice().getDeviceCapabilities();

        //if (deviceCaps != null && !deviceCaps.contains("no_pop") && securityType != AppConstants.SEC_TYPE_0) {
        if (deviceCaps != null && !deviceCaps.contains("no_pop")) {
            Log.d(TAG, "!deviceCaps.contains(\"no_pop\")");
//            goToPopActivity();

        } else if (deviceCaps.contains("wifi_scan")) {
            Log.d(TAG, "deviceCaps.contains(\"wifi_scan\")");
            getDeviceID();

        } else {
            Log.d(TAG, "33333333333");
//            goToWiFiConfigActivity();
        }
    }

    class CGetDeviceID {
        private String order;

        public CGetDeviceID(String order){
            this.order = order;
        }
    }

    class CSetID {
        private String order;
        private String accountID;

        public CSetID(String order, String accountID){
            this.order = order;
            this.accountID = accountID;
        }
    }

    class CSetMQTT {
        private String order;
        private String ip;
        private String port;
        private String id;
        private String pw;

        public CSetMQTT(String order, String ip, String port, String id, String pw){
            this.order = order;
            this.ip = ip;
            this.port = port;
            this.id = id;
            this.pw = pw;
        }
    }

    private void getDeviceID() {

        CGetDeviceID getDeviceIDConfig = new CGetDeviceID("getDeviceID");
        Gson gson = new GsonBuilder().setPrettyPrinting().create();

        byte[] result = gson.toJson(getDeviceIDConfig).getBytes(StandardCharsets.UTF_8);

//        Log.i(TAG, Arrays.toString(result));
//        Log.i(TAG, new String(result));
        provisionManager.getEspDevice().sendDataToCustomEndPoint("custom-data", result, new ResponseListener() {

            @Override
            public void onSuccess(final byte[] returnData) {
                Log.i(TAG, ">>> getDeviceID() - sendData response  : " + new String(returnData));
//                Log.i(TAG, ">>> sendData response length : " + returnData.length);

                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        try {
                            hubID = new String(returnData, "US-ASCII");
                        } catch (UnsupportedEncodingException e){

                        }
                    }
                });

                setAccountID();
            }

            @Override
            public void onFailure(Exception e) {
                Log.d(TAG, e.toString());
                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        closeErrorActivity("Failed to doDeviceConfig_3");
                    }
                });
            }
        });
    }

    private void setAccountID() {
        CSetID idConfig = new CSetID("setID", accountID);

        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        byte[] result = gson.toJson(idConfig).getBytes(StandardCharsets.UTF_8);

        Log.i(TAG, "1 " + Arrays.toString(result));
        Log.i(TAG, "2 " + new String(result));

        provisionManager.getEspDevice().sendDataToCustomEndPoint("custom-data", result, new ResponseListener() {

            @Override
            public void onSuccess(final byte[] returnData) {
                Log.i(TAG, ">>> setAccountID() - sendData response  : " + new String(returnData));
//                Log.i(TAG, ">>> sendData response length : " + returnData.length);

                setMqtt();
                //getKeyValue();
            }

            @Override
            public void onFailure(Exception e) {
                closeErrorActivity("Failed to doDeviceConfig_2()");
            }
        });
    }

    private void setMqtt() {
        CSetMQTT mqttConfig = new CSetMQTT("setMQTT", serverIp, serverPort, userID, userPw);
        Gson gson = new GsonBuilder().setPrettyPrinting().create();

        byte[] result = gson.toJson(mqttConfig).getBytes(StandardCharsets.UTF_8);

        Log.i(TAG, "1 " + Arrays.toString(result));
        Log.i(TAG, "2 " + new String(result));

        provisionManager.getEspDevice().sendDataToCustomEndPoint("custom-data", result, new ResponseListener() {

            @Override
            public void onSuccess(final byte[] returnData) {
                Log.i(TAG, ">>> setMqtt() - sendData response  : " + new String(returnData));
//                Log.i(TAG, ">>> sendData response length : " + returnData.length);

                mainActivityResult.success(hubID);
            }

            @Override
            public void onFailure(Exception e) {
                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        closeErrorActivity("Failed to doDeviceConfig_3()");
                    }
                });
            }
        });
    }

    private void startWifiScan() {
        Log.d(TAG, "Start Wi-Fi Scan");
        wifiAPList.clear();

        provisionManager.getEspDevice().scanNetworks(new WiFiScanListener() {

            @Override
            public void onWifiListReceived(final ArrayList<WiFiAccessPoint> wifiList) {

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        wifiAPList.addAll(wifiList);
                        completeWifiList();
                    }
                });
            }

            @Override
            public void onWiFiScanFailed(Exception e) {

                // TODO
                Log.e(TAG, "onWiFiScanFailed");
                e.printStackTrace();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        closeErrorActivity("Failed to get Wi-Fi scan list");
                    }
                });
            }
        });
    }

    private void completeWifiList() {

        try {
            if (!wifiAPList.isEmpty()) {
                JSONArray jsonArr = new JSONArray();
                for (int i = 0; i < wifiAPList.size(); i++) {
                    WiFiAccessPoint ap = wifiAPList.get(i);

                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("WifiName", ap.getWifiName());
                    jsonObj.put("rssi", ap.getRssi());
                    jsonObj.put("security", ap.getSecurity());
                    jsonObj.put("password", ap.getPassword());

                    jsonArr.put(jsonObj);
                }

                String data = jsonArr.toString();
                mainActivityResult.success(data);
            } else {
                Log.e(TAG, "================= AP Empty");
                if (provisionManager != null && provisionManager.getEspDevice() != null) {
                    provisionManager.getEspDevice().disconnectDevice();
                }
                mainActivityResult.error("APListEmpty", "APList is Empty", null);
            }

        } catch (JSONException e) {
            e.printStackTrace();
            closeErrorActivity("Failed to Wifi Scan()");
        }
    }

    private Runnable disconnectDeviceTask = new Runnable() {

        @Override
        public void run() {
            Log.e(TAG, "Disconnect device");
            closeErrorActivity("Communication failed. Device may not be supported.");
        }
    };

    private void closeErrorActivity(String msg) {
        if (provisionManager != null && provisionManager.getEspDevice() != null) {
            provisionManager.getEspDevice().disconnectDevice();
        }
//        EventBus.getDefault().unregister(this);
        mainActivityResult.error("UNAVAILABLE", msg, null);
    }

    private void requestBluetoothEnable() {

        Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        Log.d(TAG, "Requested user enables Bluetooth.");
    }

    private boolean hasLocationPermissions() {
        if (VERSION.SDK_INT >= VERSION_CODES.M) {
            return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
        }
        return true;
    }

    private void requestLocationPermission() {
        if (VERSION.SDK_INT >= VERSION_CODES.M) {
            requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_FINE_LOCATION);
        }
    }

    private void askForLocation() {

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setCancelable(true);
        builder.setMessage("Location services are disabled. Please enable them to continue");

        // Set up the buttons
        builder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {

                startActivityForResult(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS), REQUEST_LOCATION);
            }
        });

        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }
    private boolean isLocationEnabled() {

        boolean gps_enabled = false;
        boolean network_enabled = false;
        LocationManager lm = (LocationManager) getApplicationContext().getSystemService(Activity.LOCATION_SERVICE);

        try {
            gps_enabled = lm.isProviderEnabled(LocationManager.GPS_PROVIDER);
        } catch (Exception ex) {
        }

        try {
            network_enabled = lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        } catch (Exception ex) {
        }

        Log.d(TAG, "GPS Enabled : " + gps_enabled + " , Network Enabled : " + network_enabled);

        boolean result = gps_enabled || network_enabled;
        return result;
    }
}
