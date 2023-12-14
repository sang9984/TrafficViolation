import os
from urllib.parse import quote_plus
from flask import Flask, request, jsonify, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.exceptions import HTTPException

# 이미지를 검색할 서버 프로젝트의 루트 디렉토리 내부에 스태틱 폴더를 지정
app = Flask(__name__, static_folder='/Users/yoon-woosang/Desktop/programing/swift/project/DatabaseQuery/server/static/')

# MySQL 테이블과 연동을 위해 입력해야 할 사항들을 변수로 저장
password = "Sang9984@!" #mysql root의 비밀번호
HOST = 'localhost' # 호스트
USERNAME = "root" # 유저이름
PASSWORD = quote_plus(password) #비밀번호를 저장한 변수를 비밀번호에 입력
DATABASE_NAME = "test" # 데이터베이스 이름

# SQLAlchemy 설정 - 환경변수를 기반으로 url에 대한 접근을 지정
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{USERNAME}:{PASSWORD}@{HOST}:3306/{DATABASE_NAME}?charset=utf8mb4'
db = SQLAlchemy(app)

# 모델 클래스를 지정
# (차량 번호, 위반 날짜, 위반 시간)이 하나의 키가 된다
# 외래키는 CheckPoint 테이블의 location을 참조한다
class CheckPoint(db.Model):
    __tablename__ = 'CheckPoint'

    location = db.Column(db.String(255), primary_key=True)
    lat = db.Column(db.Float, nullable=False)
    lon = db.Column(db.Float, nullable=False)
    speed_limit = db.Column(db.Integer, nullable=False)

    # TrafficViolation과의 관계 설정
    violations = db.relationship('TrafficViolation', backref='Checkpoint')

    @property
    def serialize(self):
        return {
            'location': self.location,
            'lat': self.lat,
            'lon': self.lon,
            'speed_limit': self.speed_limit
        }

class TrafficViolation(db.Model):
    __tablename__ = 'TrafficViolations'

    car_number = db.Column(db.String(255), primary_key=True)
    overspeed = db.Column(db.Integer, nullable=False)
    location = db.Column(db.String(255), db.ForeignKey('CheckPoint.location'), nullable=False)
    violation_time = db.Column(db.Time, primary_key=True)
    violation_date = db.Column(db.Date, primary_key=True)
    image_path = db.Column(db.String(255), nullable=False)
    @property
    def serialize(self):
        image_url = url_for('static', filename=f'images/testImage/{os.path.basename(self.image_path)}', _external=True)
        return {
            'car_number': self.car_number,
            'overspeed': self.overspeed,
            'location': self.location,
            'violation_time': self.violation_time.isoformat() if self.violation_time else None,
            'violation_date': self.violation_date.isoformat() if self.violation_date else None,
            'image_path': image_url  # 이미지 파일의 상대 경로를 반환
        }

# API 키 검증 함수
# 키를 저장하는 배열을 생성하고 매개변수로 받은 키가 정당한 권한을 가진 키인지 확인하는 함수
def check_api_key(api_key):
    valid_api_keys = ['y76080482ws984ldj9042gbddsdd472913', 'df0dd0ld3njn4m5bn4bmnnl257mmor']
    return api_key in valid_api_keys

# TrafficViolations 테이블의 모든 레코드를 조회하는 기능
# 우선 api_key를 체크하고 권한이 유효하면 모든 데이터를 데이터베이스로부터 가져온다
# 만약 데이터의 부재가 발생할 경우 예외처리를 통해 서버가 다운되지 않도록 한다
# 결과로 상태코드를 반환한다
@app.route('/TrafficViolations/get_all_record/<api_key>', methods=["GET"])
def get_all_records(api_key):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    try:
        # 조인된 데이터 가져오기
        records = db.session.query(
            TrafficViolation.car_number,
            TrafficViolation.overspeed,
            CheckPoint.speed_limit,
            TrafficViolation.location,
            TrafficViolation.violation_time,
            TrafficViolation.violation_date,
            TrafficViolation.image_path
        ).join(CheckPoint, TrafficViolation.location == CheckPoint.location).all()

        # 조인을 통한 새로운 태이블의 생성에 따라 새로운 테이블에 대한 속성을 다루기 위해 새로운 딕셔너리를 생성해 json으로 변환하는 작업
        results = []
        for record in records:
            result = {
                'car_number': record[0],
                'overspeed': record[1],
                'speed_limit': record[2],
                'location': record[3],
                'violation_time': record[4].isoformat() if record[4] else None,
                'violation_date': record[5].isoformat() if record[5] else None,
                'image_path': url_for('static', filename=f'images/testImage/{os.path.basename(record[6])}',
                                      _external=True)
            }
            results.append(result)

        return jsonify(results), 200
    except Exception as e:
        app.logger.error(f"Error fetching records: {e}")
        return jsonify({'error': str(e)}), 500

# CheckPoint 테이블의 모든 레코드를 조회하는 기능
# 우선 api_key를 확인하고 권한이 유효하면 모든 데이터를 데이터베이스로부터 가져온다
# 만약 데이터의 부재가 발생할 경우 예외처리를 통해 서버가 다운되지 않도록 한다
# 결과로 상태 코드를 반환한다
@app.route('/CheckPoint/get_all_record/<api_key>', methods=["GET"])
def get_all_records_CheckPoint(api_key):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    try:
        records = CheckPoint.query.all()
        return jsonify([record.serialize for record in records]), 200
    except HTTPException as http_e:
        raise http_e
    except Exception as e:
        app.logger.error(f"Unexpected error: {e}")
        return jsonify({'error': 'An unexpected error has occurred.'}), 500

# 레코드 삽입 기능
# TrafficViolations 테이블에 새로운 레코드를 삽입한다
# 새로운 레코드에 대한 primary key는 car_number, violation_date, violation_time이 된다

@app.route('/TrafficViolations/insert_record/<api_key>', methods=['POST'])
def insert_record(api_key):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    try:
        data = request.get_json()
        new_car = TrafficViolation(
            car_number=data['car_number'],
            overspeed=data['overspeed'],
            location=data['location'],
            violation_time=data['violation_time'],
            violation_date=data['violation_date'],
            image_path=data['image_path']
        )

        db.session.add(new_car)
        db.session.commit()
        return jsonify({'message': 'New record added successfully.'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# 이미지를 업로드하기 위해 사용하는 함수
# api_key에 대한 권한을 확인
# 이미지를 로컬 디렉토리 내부로 지정하고 url을 생성해 이미지로 저장
@app.route('/TrafficViolations/upload_image/<api_key>', methods=['POST'])
def upload_image(api_key):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    image_file = request.files['file']
    if image_file:
        filename = image_file.filename
        save_path = os.path.join(app.static_folder, 'images/testImage', filename)
        image_file.save(save_path)

        image_url = url_for('static', filename='images/testImage/' + filename, _external=True)
        return jsonify({'imagePath': image_url}), 200
    else:
        return jsonify({'error': 'No image file provided'}), 400

# 레코드 삭제 기능
@app.route('/TrafficViolations/delete/<car_number>/<violation_date>/<violation_time>/<api_key>', methods=["DELETE"])
def delete_record(api_key, car_number, violation_date, violation_time):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    try:
        # URL로부터 받은 날짜와 시간 문자열을 datetime 객체로 변환
        formatted_violation_date = datetime.strptime(violation_date, '%Y-%m-%d').date()
        formatted_violation_time = datetime.strptime(violation_time, '%H:%M:%S').time()

        # 복합 키를 사용하여 레코드 조회
        record = TrafficViolation.query.filter_by(
            car_number=car_number,
            violation_date=formatted_violation_date,
            violation_time=formatted_violation_time
        ).first()

        if record is None:
            return jsonify({'error': 'Record not found.'}), 404

        db.session.delete(record)
        db.session.commit()
        return jsonify({'message': 'Record deleted successfully.'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# 레코드를 업데이트 하는 기능
@app.route('/TrafficViolations/update_record/<car_number>/<violation_date>/<violation_time>/<api_key>', methods=['PUT'])
def update_record(api_key, car_number, violation_date, violation_time):
    if not check_api_key(api_key):
        return jsonify({'error': 'Invalid API key.'}), 403

    try:
        data = request.get_json()

        # URL로부터 받은 날짜와 시간 문자열을 datetime 객체로 변환
        formatted_violation_date = datetime.strptime(violation_date, '%Y-%m-%d').date()
        formatted_violation_time = datetime.strptime(violation_time, '%H:%M:%S').time()

        # 복합 키를 사용하여 레코드 조회
        record = TrafficViolation.query.filter_by(
            car_number=car_number,
            violation_date=formatted_violation_date,
            violation_time=formatted_violation_time
        ).first()

        if record:
            # 기본 키가 아닌 다른 필드 업데이트
            record.overspeed = data.get('overspeed', record.overspeed)
            record.location = data.get('location', record.location)
            record.image_path = data.get('image_path', record.image_path)

            db.session.commit()
            return jsonify({'message': 'Record updated successfully.'}), 200
        else:
            return jsonify({'error': 'Record not found.'}), 404

    except Exception as e:
        app.logger.error(f"Update error: {e}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=443)
