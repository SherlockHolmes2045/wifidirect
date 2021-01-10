package com.sherlock2045.siuu_tchat;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.wifi.WifiManager;
import android.net.wifi.p2p.WifiP2pConfig;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pDeviceList;
import android.net.wifi.p2p.WifiP2pInfo;
import android.net.wifi.p2p.WifiP2pManager;
import android.os.AsyncTask;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;


import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "samples.flutter.dev/battery";

    public static final String STREAM = "com.sherlock2045.eventchannel/stream";

    public static final String MESSAGE = "com.sherlock2045.eventchannel/messages";

    public static final String TAG = "eventchannelsample";

    WifiP2pManager mManager;
    WifiP2pManager.Channel mChannel;
    WifiManager wifiManager;
    BroadcastReceiver mReceiver;
    private Map<Object, Runnable> listeners = new HashMap<>();

    private static final int MY_ACCESS_REQUEST_CODE = 100;
    private List<WifiP2pDevice> peers = new ArrayList<>();
    String[] deviceNameArray;
    WifiP2pDevice[] deviceArray;
    IntentFilter mIntentFilter;

    static final int MESSAGE_READ = 1;

    private Disposable timerSubscription;

    Server server;
    Client client;
    SendReceive sendReceive;
    List<String> messages = new ArrayList<>();
    List<String> messagesCopy = new ArrayList<>();

    boolean newMessage = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initialWork();
        exqListener();

    }

    Handler handler = new Handler(new Handler.Callback(){

        @Override
        public boolean handleMessage(@NonNull Message msg) {
            switch (msg.what)
            {
                case MESSAGE_READ:
                    byte[] readBuff = (byte[]) msg.obj;
                    String tempMsg = new String(readBuff,0,msg.arg1);
                    addMessage(tempMsg);
                    newMessage = true;
                    System.out.println(messages);
                    System.out.println("received message" + tempMsg);
                    //send text
                    break;
            }
            return true;
        }
    });

    void addMessage(String message){
        messages.add(message);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();

                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else if (call.method.equals("discover")) {
                                discover();
                                result.success("yes");
                            }else if( call.method.equals("getDevices")) {
                                result.success(getDevices());
                            }else if( call.method.equals("connectToPeer")) {
                                String address = call.argument("address");
                                connectToPeer(address);
                                result.success("yes");
                            }else if(call.method.equals("sendMessage")){
                                String message = call.argument("message");
                                String type = call.argument("type");
                                sendMessage(message,type);
                                result.success("good");
                            } else {
                                result.notImplemented();
                            }
                        }
                );

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STREAM).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object listener, EventChannel.EventSink eventSink) {
                        Log.w(TAG, "adding listener");
                        startListening(listener, eventSink);
                    }

                    @Override
                    public void onCancel(Object listener) {
                        Log.w(TAG, "cancelling listener");
                        cancelListening(listener);
                    }
                });
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),MESSAGE).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        Log.w(TAG,"listening to messages");
                        timerSubscription = Observable
                                .interval(0, 1, TimeUnit.SECONDS)
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe(
                                        (Long timer) -> {
                                            Log.w(TAG, newMessage + "");
                                            if(newMessage)
                                            {
                                                System.out.println("sending message to flutter");
                                                events.success(messages.size()>0 ? messages.get(messages.size()-1) : null);
                                                newMessage = false;
                                            }


                                        },
                                        (Throwable error) -> {
                                            Log.e(TAG, "error in emitting timer", error);
                                            events.error("STREAM", "Error in processing observable", error.getMessage());
                                        },
                                        () -> Log.w(TAG, "closing the timer observable")
                                );
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        Log.w(TAG, "cancelling listener");
                        if (timerSubscription != null) {
                            timerSubscription.dispose();
                            timerSubscription = null;
                        }
                    }
                }
        );
    }

    @Override
    public void onResume() {
        super.onResume();
        registerReceiver(mReceiver, mIntentFilter);
    }

    @Override
    public void onPause() {
        super.onPause();
        unregisterReceiver(mReceiver);
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }


    private Map<HashMap<String,String>,HashMap<String,String>> getDevices() {
        Map<HashMap<String,String>,HashMap<String,String>> devices = new HashMap<HashMap<String,String>,HashMap<String,String>>();
        for (int i = 0; i < peers.size(); i++){
            HashMap<String,String> newMap1 = new HashMap<String,String>();
            HashMap<String,String> newMap2 = new HashMap<String,String>();
            newMap1.put("name",peers.get(i).deviceName);
            newMap2.put("address",peers.get(i).deviceAddress);
            devices.put(newMap1,newMap2);
        };
        return devices;
    }

    private void initialWork() {

        wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

        mManager = (WifiP2pManager) getSystemService(Context.WIFI_P2P_SERVICE);
        mChannel = mManager.initialize(this, getMainLooper(), null);

        mReceiver = new WiFiDirectBroadcastReceiver(mManager, mChannel, this);

        mIntentFilter = new IntentFilter();
        mIntentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION);
        mIntentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION);
        mIntentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION);
        mIntentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION);
    }

    WifiP2pManager.PeerListListener peerListListener = new WifiP2pManager.PeerListListener() {
        @Override
        public void onPeersAvailable(WifiP2pDeviceList peerList) {
            if (!peerList.getDeviceList().equals(peers)) {
                peers.clear();
                peers.addAll(peerList.getDeviceList());

                deviceNameArray = new String[peerList.getDeviceList().size()];
                deviceArray = new WifiP2pDevice[peerList.getDeviceList().size()];

                int index = 0;

                for (WifiP2pDevice device : peerList.getDeviceList()) {
                    deviceNameArray[index] = device.deviceName;
                    deviceArray[index] = device;
                    index++;
                }
                System.out.println(Arrays.toString(deviceNameArray));
                System.out.println(Arrays.toString(deviceArray));
            }

            if (peers.size() == 0) {
                System.out.println("No devices found");
                return;
                //send no device found
            }
        }
    };

    WifiP2pManager.ConnectionInfoListener connectionInfoListener = new WifiP2pManager.ConnectionInfoListener(){

        @Override
        public void onConnectionInfoAvailable(WifiP2pInfo info) {
            final InetAddress groupOwnerAddress = info.groupOwnerAddress;
            if(info.groupFormed && info.isGroupOwner)
            {
                System.out.print("Host");
                server = new Server();
                server.start();
            }else if(info.groupFormed){
                System.out.print("client");
                client = new Client(groupOwnerAddress);
                client.start();
            }
        }
    };

    private void exqListener() {
        if (wifiManager.isWifiEnabled()) {
            wifiManager.setWifiEnabled(false);

        } else {
            wifiManager.setWifiEnabled(true);
        }
    }

    private void discover() {
        System.out.println("Discovering");
        if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(MainActivity.this, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, MY_ACCESS_REQUEST_CODE);
        }
        mManager.discoverPeers(mChannel, new WifiP2pManager.ActionListener() {
            @Override
            public void onSuccess() {
                System.out.println("success starting discovery mode");
            }

            @Override
            public void onFailure(int reason) {

                System.out.println("Fail to start discovery mode");

            }
        });
    }

    private String[] getDevicesList() {
        return deviceNameArray;
    }

    void startListening(Object listener, EventChannel.EventSink emitter) {
        // Prepare a timer like self calling task
        final Handler handler = new Handler();
        listeners.put(listener, new Runnable() {
            @Override
            public void run() {
                if (listeners.containsKey(listener)) {
                    // Send some value to callback

                    emitter.success(deviceNameArray != null ? "hello" : deviceNameArray);
                    handler.postDelayed(this, 1000);
                }
            }
        });
        // Run task
        handler.postDelayed(listeners.get(listener), 1000);
    }
    void listenMessage(Object listener, EventChannel.EventSink emitter){
        final Handler handler = new Handler();
        listeners.put(listener, new Runnable() {
            @Override
            public void run() {
                System.out.println("listener running");
                if(listeners.containsKey(listener)){
                    System.out.println("enter listener at least");
                    if(messages.size() != messagesCopy.size())
                    {
                        System.out.println("sending message to flutter");
                        emitter.success(messages.size()>0 ? messages.get(messages.size()-1) : null);
                        handler.postDelayed(this, 1000);
                    }
                }
                messagesCopy = messages;
            }
        });
        handler.postDelayed(listeners.get(listener), 1000);
    }

    void cancelListening(Object listener) {
        // Remove callback
        listeners.remove(listener);
    }

    void connectToPeer(String address) {

        WifiP2pConfig config = new WifiP2pConfig();
        config.deviceAddress = address;

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(MainActivity.this, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, MY_ACCESS_REQUEST_CODE);
        }
        mManager.connect(mChannel, config, new WifiP2pManager.ActionListener() {

            @Override
            public void onSuccess() {

                System.out.println("Successfully Connected");
            }

            @Override
            public void onFailure(int reason) {
                System.out.println("Connection failed");
            }
        });

    }

    @SuppressLint("StaticFieldLeak")
    public class MyTask extends AsyncTask<String, Void, Void> {


        @Override
        protected Void doInBackground(String... strings) {

            String[] msgs = strings.clone();
            String msg = msgs[0];
            sendReceive.write(msg.getBytes());

            return null;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            System.out.println("message send");
        }
    }

    void sendMessage(String message,String type){
        new MyTask().execute(message + " " + type);;
    }

    private class SendReceive extends Thread{

        private Socket socket;
        private InputStream inputStream;
        private OutputStream outputStream;

        public SendReceive(Socket sckt){
            socket = sckt;
            try{
                inputStream = socket.getInputStream();
                outputStream = socket.getOutputStream();
            }catch (IOException e){
                e.printStackTrace();
            }

        }

        @Override
        public void run(){
            byte[] buffer = new byte[1024];
            int bytes;

            while (socket != null)
            {
                 try{
                     bytes = inputStream.read(buffer);
                     if(bytes > 0)
                     {
                         handler.obtainMessage(MESSAGE_READ,bytes,1,buffer).sendToTarget();
                     }
                 }catch (IOException e){
                     e.printStackTrace();
                 }
            }
        }

        public void write(byte[] bytes){
            try{
                outputStream.write(bytes);
            }catch (IOException e){
                e.printStackTrace();
            }
        }
    }
    public class Server extends Thread{
        Socket socket;
        ServerSocket serverSocket;


        @Override
        public void run(){
            try{
                serverSocket = new ServerSocket(8888);
                socket = serverSocket.accept();
                sendReceive = new SendReceive(socket);
                sendReceive.start();
            } catch (IOException e){
                e.printStackTrace();
            }
        }
    }

    public class Client extends Thread{

        Socket socket;
        String hostAdd;

        public  Client(InetAddress hostAddress){
            hostAdd = hostAddress.getHostAddress();
            socket = new Socket();
        }

        @Override
        public void run(){
            try{

                socket.connect(new InetSocketAddress(this.hostAdd,8888),500 );
                sendReceive = new SendReceive(socket);
                sendReceive.start();
            } catch (IOException e){
                e.printStackTrace();
            }
        }
    }
}


