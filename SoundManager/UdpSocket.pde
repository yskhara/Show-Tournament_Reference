import hypermedia.net.*;
import java.util.Calendar;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;


public class UdpSocket {
  UDP udp;
  
  private volatile boolean port_get = false;
  private int kam_port = -1;
  private String server_ip = "";
  
  private String show_mode = "home";
  private Calendar start_time = Calendar.getInstance();
  private int[] point_list = {0,0};
 
  UdpSocket(){
    udp = new UDP(this, 58239);
  
    if(udp.isClosed() == true) {
      JFrame f = new JFrame();
      JLabel label = new JLabel("UDP Port 58239 is already used.");
      JOptionPane.showMessageDialog(f, label);
      System.exit(1);
    }
      
    udp.listen(true);

  }
  
  public String get_show_mode(){
    return show_mode;
  }

  public long get_now_time(){
    long now_ms = Calendar.getInstance().getTimeInMillis();
    return now_ms - start_time.getTimeInMillis();
  }
  
  public int get_point(int i){
    if( i == 0 | i ==1 ){
      return point_list[i];
    }else{
      return -1;
    }
  }

 
  public void receive(byte[] data) {
    String[] pac_data;
    {
      BufferedReader buf_reader = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(data)));
      ArrayList<String> buf_array = new ArrayList<String>();
      String line;
      try {
        while( (line = buf_reader.readLine()) != null){
          buf_array.add(line);
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
      pac_data = buf_array.toArray(new String[buf_array.size()]);
    }
    
    if(pac_data[0].equals("server")){
      // ------------------------------------------
      // server state packet
      // ------------------------------------------
      for(int i = 1; i < pac_data.length; i++){
        String[] line = pac_data[i].split(",");
        if(line.length == 2){
          if( line[0].equals("kam_port") ){
            kam_port = int(line[1]);
            port_get = true;
          }
        }
      }
      
    }else if(pac_data[0].equals("show")){
      // ------------------------------------------
      // show state packet
      // ------------------------------------------
      // show packet id
      String id = pac_data[1];
      
      // show mode
      show_mode = pac_data[3];
      
      // start time
      String[] str_start_time = pac_data[4].split(",");
      if( str_start_time.length == 7){
        start_time = Calendar.getInstance();
        start_time.set(Calendar.YEAR, int(str_start_time[0]));
        start_time.set(Calendar.MONTH, int(str_start_time[1]));
        start_time.set(Calendar.DATE, int(str_start_time[2]));
        start_time.set(Calendar.HOUR_OF_DAY, int(str_start_time[3]));
        start_time.set(Calendar.MINUTE, int(str_start_time[4]));
        start_time.set(Calendar.SECOND, int(str_start_time[5]));
        start_time.set(Calendar.MILLISECOND, int(str_start_time[6]));
      }
      
      // point list
      String[] str_point = pac_data[5].split(",");
      if( str_point.length == 2 ){
        point_list[0] = int(str_point[0]);
        point_list[1] = int(str_point[1]);
      }
      
      // send keep alive
      if( port_get == true ){
        udp.send(id + ",Score Board", server_ip, kam_port);
      }
      
    }else{
      // ------------------------------------------
      // unknown packet state packet
      // ------------------------------------------
      
    }
  }
  
  public void close(){
    udp.close();
  }


}