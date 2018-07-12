package triopu.hrvfeatureextractor;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import hrv.RRData;
import hrv.calc.parameter.HRVParameter;
import units.TimeUnit;

public class MainActivity extends Activity implements View.OnClickListener {

    private final int REQUEST_CODE_PICK_DIR = 1;
    private final int REQUEST_CODE_PICK_FILE = 2;
    String newDir   = "";
    String saveDir  = "";
    String newFile  = "";
    String fileName = "";

    Button browseFolder,startCalc;
    EditText nameFile;

    Integer sgm     = 30;

    double seg;

    double  theBeavsky, theHF, theLF, theMean, theNN50,
            thePNN50, theRMSSD, theSD1,
            theSD2, theSD1SD2, theSDNN, theSDSD, LFHF;

    public void onBackPressed(){
        new AlertDialog.Builder(this).setIcon(android.R.drawable.ic_dialog_alert).setTitle("Exit")
                .setMessage("Are you sure?")
                .setPositiveButton("yes", new DialogInterface.OnClickListener(){
                    @Override
                    public  void onClick(DialogInterface dialog, int which){
                        Intent intent = new Intent(Intent.ACTION_MAIN);
                        intent.addCategory(Intent.CATEGORY_HOME);
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        startActivity(intent);
                        finish();
                        System.exit(0);
                    }
                }).setNegativeButton("no", null).show();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        LinearLayout background = (LinearLayout) findViewById(R.id.activity_main);
        background.setBackgroundColor(Color.WHITE);

        browseFolder = (Button)findViewById(R.id.browseFolder);
        browseFolder.setOnClickListener(this);
        startCalc = (Button)findViewById(R.id.startCalc);
        startCalc.setOnClickListener(this);

        nameFile = (EditText)findViewById(R.id.fileName);
        nameFile.setMovementMethod(new ScrollingMovementMethod());
        nameFile.setTextColor(Color.WHITE);
    }

    public void saveIt(Double dBeavsky, Double dHF, Double dLF, Double dMean, Double dNN50,
                       Double dPNN50, Double dRMSSD, Double dSD1,
                       Double dSD2, Double dSD1SD2, Double dSDNN, Double dSDSD){
        try {
            @SuppressLint("DefaultLocale")
            String printFormat = String.format("%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f",
                    dBeavsky, dHF, dLF, dMean,
                    dNN50, dPNN50, dRMSSD, dSD1,
                    dSD2, dSD1SD2, dSDNN, dSDSD);
            //Log.d("Penyimpanan",fileName);
            printFormat = printFormat.replace(',','.');
            Log.d("Get Data",printFormat);
            FileWriter fw = new FileWriter(fileName, true);
            fw.append(printFormat+"\n");
            fw.flush();
            fw.close();
        } catch (IOException e) {
        }
    }

    public void startCalculation(){
        newDir  = "/storage/emulated/0/AARRFeature";
        saveDir = "/storage/emulated/0/Saved";

        File root = new File(saveDir);
        if (!root.exists()) {
            root.mkdirs();
        }

        File folder = new File(newDir);
        List theFile = getListFiles(folder);
        //Log.d("List", String.valueOf(theFile.get(0)));

        for (int i=0;i < theFile.size();i++) {
            newFile = String.valueOf(theFile.get(i));
            nameFile.setText(newFile.substring((newFile.length()-8)));
            fileName = saveDir+"/"+"SaveData"+newFile.substring((newFile.length()-8),(newFile.length()-4))+".txt";
            Log.d("Processing",fileName);//newFile.substring((newFile.length()-8)));
            if (newFile.indexOf('/') == 0) {
                File file = new File(newFile);
                String[] intRR = loadRR(file);
                String[] timeRR = loadTime(file);
                //Log.d("RR",String.valueOf(intRR.length));
                featureExtraction(intRR,timeRR);
                newFile = "";
            } else {
                Toast.makeText(this, "No File!", Toast.LENGTH_LONG).show();
            }
        }
    }

    public void featureExtraction(String[] itRR, String[] tmRR){
        double[] iRR = new double[itRR.length];
        for(int i=0; i < itRR.length; i++){
            iRR[i] = Double.valueOf(itRR[i]);
        }
        double[] tRR = new double[tmRR.length];
        for(int i=0; i < tmRR.length; i++){
            tRR[i] = Double.valueOf(tmRR[i]);
        }

        //Log.d("Real RR", String.valueOf(iRR));

        int m = 0;

        List<Integer> limDown    = new ArrayList<>();
        List<Integer> limUp      = new ArrayList<>();

        Log.d("tRR",String.valueOf(tRR[0]));

        for(int n = 1; n<28; n++){
            seg = n*20;
            //n = m;
            limDown.add(m);
            while (tRR[m] < seg){
                if (m < iRR.length) m = m+1;
                else seg = (int)tRR[m-1];

                if(m >= tRR.length) break;
            }
            limUp.add(m-1);
        }

        /*Log.d("Length LimitD is",String.valueOf(limDown.size()));*/

        for(int d = 0; d<limUp.size();d++){
            Log.d("Limit is",String.valueOf(limDown.get(d))+" to "+String.valueOf(limUp.get(d)));
        }


        for(int u = 0; u<27; u++){
            int up = limUp.get(u);
            int down = limDown.get(u);

            List<Double> rrData    = new ArrayList<>();
            List<Double> rrTime      = new ArrayList<>();

            for(int k = down; k<up; k++){
                rrData.add(iRR[k]);
                rrTime.add(tRR[k]);
            }

            double[] dataRR     = new double[rrData.size()];
            double[] dataTime   = new double[rrTime.size()];

            for(int f = 0; f < rrData.size(); f++){
                dataRR[f] = rrData.get(f);
                dataTime[f] = rrTime.get(f);
            }

            calcFeature(dataRR, dataTime);
        }
    }

    public void calcFeature(double[] RRdata, double[] RRtime) {

        RRData rr = new RRData(RRtime, TimeUnit.SECOND, RRdata, TimeUnit.SECOND);

        HRVCalculatorFacade controller = new HRVCalculatorFacade(rr);

        HRVParameter HF = controller.getHF(); theHF = HF.getValue(); theHF = round(theHF,3);
        HRVParameter LF = controller.getLF(); theLF = LF.getValue(); theLF = round(theLF,3);
        HRVParameter Beavsky = controller.getBaevsky(); theBeavsky = Beavsky.getValue(); theBeavsky = round(theBeavsky,3);
        HRVParameter Mean = controller.getMean(); theMean = Mean.getValue(); theMean = round(theMean,3);
        HRVParameter NN50 = controller.getNN50(); theNN50 = NN50.getValue(); theNN50 = round(theNN50,3);
        HRVParameter PNN50 = controller.getPNN50(); thePNN50 = PNN50.getValue(); thePNN50 = round(thePNN50,3);
        HRVParameter RMSSD = controller.getRMSSD(); theRMSSD = RMSSD.getValue(); theRMSSD = round(theRMSSD,3);
        HRVParameter SD1 = controller.getSD1(); theSD1 = SD1.getValue(); theSD1 = round(theSD1,3);
        HRVParameter SD2 = controller.getSD2(); theSD2 = SD2.getValue(); theSD2 = round(theSD2,3);
        HRVParameter SD1SD2 = controller.getSD1SD2(); theSD1SD2 = SD1SD2.getValue(); theSD1SD2 = round(theSD1SD2,3);
        HRVParameter SDNN = controller.getSDNN(); theSDNN = SDNN.getValue(); theSDNN = round(theSDNN,3);
        HRVParameter SDSD = controller.getSDSD(); theSDSD = SDSD.getValue(); theSDSD = round(theSDSD,3);

        LFHF = Math.abs(theLF/theHF);
        LFHF = round(LFHF,2);

        saveIt(theBeavsky, theHF, theLF, theMean, theNN50, thePNN50, theRMSSD, theSD1, theSD2, theSD1SD2, theSDNN, theSDSD);
    }

    public static String[] loadTime(File file) {
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        InputStreamReader isr = new InputStreamReader(fis);
        BufferedReader br = new BufferedReader(isr);

        int dataLength=0;
        try {
            while ((br.readLine()) != null) {
                dataLength++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            fis.getChannel().position(0);
        } catch (IOException e) {
            e.printStackTrace();
        }

        String sCurrentLine;
        String[] characters = new String[dataLength];
        int i = 0;
        try {
            while ((sCurrentLine = br.readLine())!=null) {
                String[] arr = sCurrentLine.split("\t");
                characters[i] = arr[0];
                i++;
            }
        } catch (IOException e) {e.printStackTrace();}
        return characters;
    }

    public static String[] loadRR(File file) {
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(file);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        InputStreamReader isr = new InputStreamReader(fis);
        BufferedReader br = new BufferedReader(isr);

        int dataLength=0;
        try {
            while ((br.readLine()) != null) {
                dataLength++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            fis.getChannel().position(0);
        } catch (IOException e) {
            e.printStackTrace();
        }

        String sCurrentLine;
        String[] characters = new String[dataLength];
        int i = 0;
        try {
            while ((sCurrentLine = br.readLine())!=null) {
                String[] arr = sCurrentLine.split("\t");
                characters[i] = arr[1];
                i++;
            }
        } catch (IOException e) {e.printStackTrace();}
        return characters;
    }

    public void browseFolder(){
        final Activity activityForButton = this;
        Log.d("Activity", "Start Browsing");
        Intent fileExplorerIntent = new Intent(triopu.hrvfeatureextractor.FileBrowserActivity.INTENT_ACTION_SELECT_DIR,null,
                activityForButton,
                triopu.hrvfeatureextractor.FileBrowserActivity.class
        );
        startActivityForResult(
                fileExplorerIntent,
                REQUEST_CODE_PICK_DIR
        );
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        if(requestCode == REQUEST_CODE_PICK_DIR){
            if(resultCode == RESULT_OK){
                newDir = data.getStringExtra(FileBrowserActivity.returnDirectoryParameter);
                Toast.makeText(this, "Received PATH from file browser:\n"+newDir, Toast.LENGTH_LONG).show();
            }else{
                Toast.makeText(this,"Received NO result from file browser", Toast.LENGTH_LONG).show();
            }
        }
        super.onActivityResult(requestCode,resultCode,data);
    }

    private List<File> getListFiles(File parentDir) {
        List<File> inFiles = new ArrayList<>();
        Queue<File> files = new LinkedList<>();
        files.addAll(Arrays.asList(parentDir.listFiles()));
        while (!files.isEmpty()) {
            File file = files.remove();
            if (file.isDirectory()) {
                files.addAll(Arrays.asList(file.listFiles()));
            } else if (file.getName().endsWith(".txt")) {
                inFiles.add(file);
            }
        }

        return inFiles;
    }

    public static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();

        long factor = (long) Math.pow(10, places);
        value = value * factor;
        long tmp = Math.round(value);
        return (double) tmp / factor;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.browseFolder:
                browseFolder();
                break;

            case R.id.startCalc:
                startCalculation();
                break;
        }
    }
}
