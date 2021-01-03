package com.sherlock2045.siuu_tchat;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.NetworkInfo;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pManager;

import androidx.core.app.ActivityCompat;

public class WiFiDirectBroadcastReceiver extends BroadcastReceiver {

    private WifiP2pManager mManager;
    private WifiP2pManager.Channel mChannel;
    private MainActivity mActivity;
    private static final int MY_ACCESS_REQUEST_CODE = 100;

    public WiFiDirectBroadcastReceiver(WifiP2pManager manager, WifiP2pManager.Channel channel, MainActivity mActivity) {
        super();
        this.mManager = manager;
        this.mChannel = channel;
        this.mActivity = mActivity;
    }


    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION.equals(action)) {

            int state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1);

            if (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED) {
                System.out.println("Wifi enable");
            } else {
                //send wifi is off
                System.out.println("Wifi disable");
            }
        } else if (WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION.equals(action)) {

            if (mManager != null) {
                if (ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

                    ActivityCompat.requestPermissions(mActivity, new String[] {Manifest.permission.CAMERA}, MY_ACCESS_REQUEST_CODE);
                }
                else
                mManager.requestPeers(mChannel, mActivity.peerListListener);
            }

        } else if (WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION.equals(action)) {

            if(mManager == null){
                return;
            }
            NetworkInfo info = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO);

            if (info != null && info.isConnected()) {
                mManager.requestConnectionInfo(mChannel, mActivity.connectionInfoListener);
            }else {
                System.out.println("Device disconnected");
            }

        } else if (WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION.equals(action)) {

            mManager.requestConnectionInfo(mChannel,mActivity.connectionInfoListener);
            WifiP2pDevice myDevice = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE);
            //LocalDevice.getInstance().setDevice(myDevice);
        }
    }
}
