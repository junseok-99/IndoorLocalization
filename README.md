<h1>iPhone을 사용한 실내 위치추정 및 AR 안내 제공 APP</h1>
<h2>1. Build</h2>
<p><b>1. Open Project</b></p>
<p><b>2. Targets -> Signing & Capabilities -> Check Teams</b></p>
<p><b>3. iPhone과 맥북 연결</b></p>
<p><b>4. Build in connected iPhone</b></p>

<br>
<hr>
<br>

<h2>2. Supported Devices & iOS</h2>
<p><b>❗️ LiDAR Scanner가 장착되지 않은 기기 지원 X</b></p>
<p><b>Device : iPhone 12 Pro 이상</b></p>
<p><b>iOS : iOS 14.0 이상</b></p>

<br>
<hr>
<br>

<h2>3. In App</h2>
<h2>- 공간등록 : 위치 추정을 서비스 할 공간을 등록하는 과정 (개발자가 진행)</h2>

<br>


<div>
  <h2>STEP 1.</h2>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/1221abf6-9f83-4ea6-977a-27b7b922be3a"/>
  <p><b>공간등록 버튼 클릭 -> 공간 이름 입력 -> 등록 시작 버튼 클릭</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 2.</h2>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/7ebc8b80-fa4a-4fb8-af39-04f296f2d397"/>
  <p><b>START 버튼 클릭 -> 공간 스캔 -> STOP 버튼 클릭</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 3.</h2>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/598af140-0b2f-4a85-9e4b-5c0a493ea1af"/>
  <p><b>연결한 iPhone Directory 접근 -> Point Cloud Document Directory -> 저장된 데이터 확인</b></p>
  
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/67d3e867-e344-48c5-9cfc-0593fb55ffb3"/>
  <p><b>House.txt : 스캔한 공간의 Point Cloud Data</b></p>
  <p><b>Pose.txt : 공간을 스캔하며 저장된 iPhone 3D Position Data</b></p>
</div>

<br>
<hr>
<div>
  <h2>RESULT (DATA VISUALIZATION).</h2>
  <p><b>House.txt</b></p>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/32d3efa4-a4bb-42b2-98ee-73264ad5fb06"/>
  
  <br><br>
  
  <p><b>Pose.txt</b></p>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/7a04efcf-9760-4e76-a0e2-3b83d2af0e3c"/>
  
  <br><br>
  
  <p><b>House.txt + Pose.txt</b></p>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/8e5d972a-7172-4d91-89d7-42dc519ef608"/>
</div>

<br>
<hr>
<br>

<h2>- 공간안내 : 사용자의 실내 위치를 추정하며 AR경험 제공으로 공간을 안내함 (사용자가 진행)</h2>

<br>


<div>
  <h2>STEP 1.</h2>
  <img width="100%" src="https://github.com/junseok-99/IndoorLocalization/assets/81612834/8e91b514-4733-4d45-8cfd-16c16a182769"/>
  <p><b>공간안내 버튼 클릭 -> 건물, 층 수 입력 -> 안내 시작 버튼 클릭</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 2.</h2>
  <p>‼️<b>현재 개발중 (23.10.17 ~ )</b></p>
</div>

<br>
<hr>
<br>

<h2>4. System Architecture</h2>
<p><b>- Space Registeration</b></p>
<img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/869b6d22-2b55-416e-bb17-5e3828458f6e"/>
<br>
<p><b>- Space Information</b></p>
<img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/704b941d-31b3-4ad2-a79f-317135307df0"/>

