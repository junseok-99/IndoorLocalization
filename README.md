<h1>iPhone을 사용한 실내 위치추정 및 AR 안내 제공 APP</h1>

<h2>💻 사용 기술 스택</h2>
<div>
  <img src="https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=swift&logoColor=white">
  
  <br>
  
  <img src="https://img.shields.io/badge/arkit-000000?style=for-the-badge&logo=arkit&logoColor=white">
  <img src="https://img.shields.io/badge/realitykit-000000?style=for-the-badge&logo=realitykit&logoColor=white">
  
  <br>
  
  
  
  <img src="https://img.shields.io/badge/xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white">
</div>

<br>
<hr>
<br>

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
  <p><b>txt 저장 형식 : x y z r g b</b></p>
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

<h2>- 공간안내 : 사용자의 실내 위치를 추정하며 AR경험 제공으로 공간 안내 (사용자가 진행)</h2>

<br>


<div>
  <h2>STEP 1.</h2>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/e25da309-80c7-4cb5-91ac-582c26483ab5"/>
  <p><b>공간안내 버튼 클릭 -> 건물, 층 수 입력 -> 안내 시작 버튼 클릭</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 2.</h2>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/dd8fa253-e1fd-4a1e-b941-69d7c19f6f9e"/>
  <p><b>서버에서 데이터를 불러옵니다.</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 3.</h2>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/23f2b325-8974-46c4-b6ff-30126c9f720d"/>
  <p><b>지정된 위치에서 우측 하단의 이미지와 화면을 일치시키고 START</b></p>
</div>

<br>
<hr>
<div>
  <h2>STEP 4.</h2>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/08d4a8af-a75a-4436-a459-15127ea1eef8"/>
  <p><b>시작 시 인트로 제공</b></p>
</div>

<br>
<div>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/d9eb85be-c4f8-48ef-8ef0-a835b9253ee1"/>
  <p><b>화면 중앙 상단에 실시간으로 사용자의 현재 위치를 알려줌</b></p>
</div>

<br>
<div>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/de821a92-116a-4a0b-a1d6-a19fda8c6989"/>
  <p><b>AR 경험으로 강의실 표지판과 시간표 제공</b></p>
</div>

<br>
<div>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/c299d2ec-9c6c-4dc1-8780-55da8d789500"/>
  <p><b>강의실 외 공간은 안내 제공</b></p>
</div>

<br>
<div>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/b3654644-e624-486e-b0f5-9186b0488d5d"/>
  <p><b>길안내 기능 제공</b></p>
  <p><b>각 공간의 유도선 색상을 알려줌</b></p>
</div>

<br>
<div>
  <img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/7e0207e5-16b0-4b62-b060-c27b4923ce96"/>
  <p><b>색상에 맞는 유도선을 따라가 원하는 곳으로 이동가능</b></p>
</div>

<br>
<hr>
<br>

<h2>4. System Architecture</h2>
<p><b>- 공간 등록</b></p>
<img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/e768259f-6a8a-42fa-a570-6f40ededddb7"/>
<br>
<p><b>- 공간 안내</b></p>
<img width="100%" src="https://github.com/junseok-99/Indoor-Server/assets/81612834/8ffded86-4d92-4248-84c2-34389016710f"/>
