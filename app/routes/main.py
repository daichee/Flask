from flask import Blueprint, render_template

# 名前空間を変更してエンドポイントの重複を避ける
main_bp = Blueprint('views', __name__)

# 「商品」クラス
class Item:
    def __init__(self, id, name):
        self.id = id
        self.name = name
    
    def __str__(self):
        return f'商品ID：{self.id} 商品名：{self.name}'

# 「ヒーロー」クラス
class Hero:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def __str__(self):
        return f'名前：{self.name} 年齢：{self.age}'

# TOPページ
@main_bp.route('/') 
def home():  # indexからhomeに変更
    return render_template('jinja/top.html')

# 一覧
@main_bp.route('/list') 
def item_list():
    return render_template('jinja/list.html')

# 詳細
@main_bp.route('/detail/<int:id>')
def item_detail(id):
    return render_template('jinja/detail.html', show_id=id)

# render_templateで値を渡す
@main_bp.route("/multiple")
def show_jinja_multiple():
    word1 = "テンプレートエンジン"
    word2 = "神社"
    return render_template('jinja/show1.html', temp=word1, jinja=word2)

# render_templateで値を渡す「辞書型」
@main_bp.route("/dict")
def show_jinja_dict():
    words = {
        'temp': "てんぷれーとえんじん",
        'jinja': "ジンジャ"
    }
    return render_template('jinja/show2.html', key=words)

# render_templateで値を渡す「リスト型」
@main_bp.route("/list2")
def show_jinja_list():
    hero_list = ['桃太郎', '金太郎', '浦島タロウ']
    return render_template('jinja/show3.html', users=hero_list)

# render_templateで値を渡す「クラス」
@main_bp.route("/class")
def show_jinja_class():
    hana = Hero('花咲かじいさん', 99)
    return render_template('jinja/show4.html', user=hana)

# 繰り返し
@main_bp.route("/for_list")
def show_for_list():
    item_list = [
        Item(1, "ダンゴ"), 
        Item(2, "にくまん"), 
        Item(3, "ドラ焼き")
    ]
    return render_template('jinja/for_list.html', items=item_list)

# # 条件分岐
# @main_bp.route('/if_detail/<int:id>')
# def show_if_detail(id):
#     item_list = [
#         Item(1, "ダンゴ"), 
#         Item(2, "にくまん"), 
#         Item(3, "ドラ焼き")
#     ]
#     return render_template('if_detail.html', show_id=id, items=item_list)

# # 条件分岐2
# @main_bp.route('/if/')
# @main_bp.route('/if/<target>')
# def show_jinja_if(target="colorless"):
#     return render_template('jinja/if_else.html', color=target)