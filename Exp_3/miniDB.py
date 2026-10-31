import json, os

SUPPORTED_TYPES = ["int", "str", "char", "varchar"]
DICT_FILE = "data_dict.json"
# 数据字典
data_dict: dict = {}

def load_dict():
    try:
        with open(DICT_FILE, "r", encoding="utf-8") as f:
            global data_dict
            data_dict = json.load(f)
            # print("成功从文件加载数据字典")
    except FileNotFoundError:
        print("文件不存在, 新建文件")
        save_dict()
    except json.JSONDecodeError:
        print("文件不是有效的 json 格式")


def save_dict():
    with open(DICT_FILE, "w", encoding="utf-8") as f:
        # 自动缩进
        json.dump(data_dict, f, indent=4)
        # print("数据字典保存成功")
 
# "CREATE TABLE student (id int, name str);"
def create_table(sql: str):
    # 先去首尾空格和分号
    # strip 去首尾空格(不写参数就是空格), rstrip 只清理右侧
    sql = sql.strip().rstrip(";")

    if ("(" not in sql or ")" not in sql):
        print("参数不足, 格式: CREATE TABLE 表名 (属性名 属性类型, .....)")
        return

    # 按 ( 分割, 拿到 CREATE TABLE student 和 id int, name str)
    front_part = sql.split("(")[0]
    # 后面部分去掉右面的 ) 就是后半部分, id int, name str
    # 可以用 , 直接分开各个属性
    back_part = sql.split("(")[1].rstrip(")")
    # print(front_part)
    # print(back_part)

    # 前半部分用空格分开, 第二个就是表名(从0开始)
    table_name = front_part.split()[2].lower()
    # print(table_name)

    # 检查数据字典里有没有同名表, 有就不行
    if table_name in data_dict:
        print("存在同名表, 无法创建")
        return

    # 建立该表文件
    open(f"{table_name}.txt", "w", encoding="utf-8").close()

    # 向字典插入一个键, 值暂时是一个空字典(里面存多种属性)
    data_dict[table_name] = {}

    # 用 , 分开各个属性, 得到 'id int', 'name str'
    # split 返回的是 List, 可以遍历每一个属性
    # 按照空格分开, 得到属性名和属性类型
    properties = back_part.split(",")
    # print(properties)

    # 遍历每一个属性
    for item in properties:
        # 通过空格分开, 得到名字和属性
        name = item.split()[0]
        type = item.split()[1].lower()

        if type not in SUPPORTED_TYPES:
            print(f"不支持类型 {type}")
            # 在字典中删除刚才建的键和文件
            del data_dict[table_name]
            os.remove(table_name + ".txt")
            return

        # name 作为内层字典的键, 因为键不重复, 数据库里的属性名也不重复
        data_dict[table_name][name] = type

    save_dict()

# "INSERT INTO student VALUES (1, '张三');"
def insert_into(sql: str):
    # 去首位空格与后面的;
    # INSERT INTO student VALUES (1, '张三')
    sql = sql.strip().rstrip(";")

    if ("(" not in sql or ")" not in sql):
        print("参数不足, 格式: INSERT INTO 表名 VALUES (...)")
        return

    # INSERT INTO student VALUES
    front_part = sql.split("(")[0]
    # 1, '张三'
    back_part = sql.split("(")[1].rstrip(")")
    # print(front_part)
    # print(back_part)

    # 检测 VALUES
    words = front_part.split()
    if len(words) < 4 or words[3].upper() != 'VALUES':
        print("语法错误, 格式: INSERT INTO 表名 VAULES (...)")
        return

    table_name = front_part.split()[2].lower()
    # print(table_name)
    
    if table_name not in data_dict:
        print(f"没有名为 {table_name} 的表")
        return

    # ['1', " '张三' "]
    properties = back_part.split(",") 

    # 去掉空格
    for i in range(len(properties)):
        properties[i] = properties[i].strip()
    # print(properties)

    if len(properties) != len(data_dict[table_name]):
        # len(字典) 返回字典的键值对数量
        print(f"表中属性数量: {len(data_dict[table_name])} 与提供属性数量: {len(properties)} 不一致")
        return

    # 按序遍历 properties
    i = 0
    # 遍历该表的属性, 与其输入的属性对应(插入属性顺序与建表顺序相同)
    # key 是 name, value 是 type
    for key, value in data_dict[table_name].items():
        # print(key, value)
        if (value == "int"):
            if not (properties[i].isdigit()):
                print(f"第 {i + 1} 个属性应为数字")
                return

        # 是字符串就去掉两个单引号
        if (value == "str" or value == "varchar" or value == "char"):
            # print(properties[i])
            # 必须先去掉空格, 要不然单引号不在最左边/最右边, strip 去不掉
            # 这个空格产生的原因是(1, '张三'), 张三的前面有个空格
            # 前面代码遍历 properties 的时候逐个去掉空格就好了
            properties[i] = properties[i].strip("'")
            # print(properties[i])
                   
        i = i + 1

    # print(properties)
    # 把插入的属性存入文件
    # "1, 张三\n"
    row: str = ""
    # range 左闭右开
    for i in range(len(properties)):
        row += properties[i]
        # 最后一个属性不加逗号
        if (i != len(properties) - 1):
            row += ","
    row += "\n"
    # print(row)
    with open(f"{table_name}.txt", "a", encoding="utf-8") as f:
        f.write(row)

    print(f"成功向表 {table_name} 插入 1 条记录")

# 传入一个字符串和一个目标宽度, 返回一个和目标宽度一样长的字符串(补空格)
def pad_str(text: str, target_width: int) -> str:
    # ljust 把汉字和英文字符都当成长度是 1 的字符
    # 但是在控制台输出的时候, 汉字显示的宽度是英文字母的 2 倍
    # ord(c) > 127 代表是汉字，宽度算 2, 否则是 ASCII 英文字符，算 1
    # ord - 计算一个字符的 Unicode(0-127和 ASCII 完全相同)
    actual_width = 0
    for c in text:
        if ord(c) < 127:
            actual_width += 1
        else:
            actual_width += 2
    # 补空格, max 是为了防止出现负数(实际长度比表长还长)
    # 如果是负数就不补
    return text + " " * max(0, target_width - actual_width)


# SELECT * FROM STUDENT;
def select_from(sql: str):
    # 去除空格和后面的 ;
    sql = sql.strip().rstrip(";")

    # 空格分割
    parts = sql.split()

    if len(parts) < 4:
        print("参数不足, 格式: SELECT * FROM 表名")
        return

    table_name = parts[3].lower()
    # print(table_name)

    # 检查是否存在
    if table_name not in data_dict:
        print(f"不存在名为 {table_name} 的表")
        return

    # 表头存到列表中
    headers = []
    for key, value in data_dict[table_name].items():
        headers.append(f"{key}({value})")
    header_line = " | ".join(headers)
    header_line = "| " + header_line + " |"
    # | 的位置, 用于把上下分隔线里面和 | 对齐的位置改成 +
    pipe_index = []
    for i in range(len(header_line)):
        if (header_line[i] == '|'):
            pipe_index.append(i)
    # print(pipe_index)
    # +-----+-----+
    # 分隔线
    divider = ""
    for i in range(len(header_line)):
        if (i in pipe_index):
            divider += "+"
        else:
            divider += "-"
    print(divider)
    print(header_line)
    print(divider)

    '''
    # 打印表的属性名及其类型
    # 遍历 data_dict[table_name], 即遍历该表里面的字典(存了该表的所有字段)
    for key, value in data_dict[table_name].items():
        print(key, value, end="")
        print("|", end="")
    print()
    '''
    # 打印文件(表数据)各行数据
    with open(f"{table_name}.txt", "r", encoding="utf-8") as f:
        for line in f:
            # 因为 print 默认会输出换行符, 所以去掉文件中的换行符
            # 按照 , 分开变成列表
            line_list = line.strip().split(",")

            # 给每个元素对齐上面的表头长度
            for i in range(len(line_list)):
                line_list[i] = pad_str(line_list[i], len(headers[i]))

            # 左右加上 |
            # 中间把对齐好的每一项用 | 分隔开
            print("| " + " | ".join(line_list) + " |")

    print(divider)

# DROP TABLE student;
def drop_table(sql: str):
    # 去前后空格与 ;
    sql = sql.strip().rstrip(";")

    parts = sql.split()

    if len(parts) < 3:
        print("参数不足, 格式: DROP TABLE 表名")
        return

    table_name = parts[2].lower()

    if (table_name not in data_dict):
        print(f"不存在名为 {table_name} 的表")
        return

    # 删除数据字典该表的键并存回文件
    del data_dict[table_name]
    save_dict()

    os.remove(f"{table_name}.txt")

    print(f"删除表 {table_name} 成功")

# DELETE FROM student;
# DELETE FROM student WHERE id = 1;
def delete_from(sql: str):
    sql = sql.strip().rstrip(";")

    parts = sql.split()

    if len(parts) < 3:
        print("参数不足, 格式: DELETE FROM 表名 或 DELETE FROM 表名 WHERE ...")
        return

    table_name = parts[2].lower()

    if table_name not in data_dict:
        print(f"不存在名为 {table_name} 的表")
        return

    # 没有 WHERE 条件直接清空
    if "WHERE" not in sql.upper():
        open(f"{table_name}.txt", "w", encoding="utf-8").close()
        print(f"已清空表 {table_name} 的所有数据")
        return

    # 有 WHERE 至少 7 个词
    if len(parts) < 7:
        print("参数不足, 格式: DELETE FROM 表名 WHERE 属性 =/>/< 值")
        return

    col_name = parts[4]
    operator = parts[5]
    # 去掉输入的引号
    target_value = parts[6].strip("'")

    # 看表里有没有这个属性
    if col_name not in data_dict[table_name]:
        print(f"表 {table_name} 中没有名为 {col_name} 的属性")
        return

    # 找到这个属性的索引(在文件中是第几列)
    # 拿出该表所有的键放在 list 里, list 的 index 方法查找某个元素在序列里第一次出现的索引位置
    index = list(data_dict[table_name].keys()).index(col_name)

    # 一行一行读取文件
    # 属性1, 属性2, .....
    # 用逗号分开
    count = 0
    rewrite_lines = ""
    with open(f"{table_name}.txt", "r", encoding="utf-8") as f:
        for line in f:
            # 用 , 分开该行的所有属性
            properties = line.strip().split(",")
            val_num = properties[index]
            target_num = target_value
            if data_dict[table_name][col_name] == "int":
                if not target_value.isdigit():
                    print(f"属性 {col_name} 是整数类型, 但提供的值 {target_value} 不是有效整数")
                    return
                val_num = int(val_num)
                target_num = int(target_value)
            if operator == '=':
                # 看要找的这个属性等不等于要找的这个值
                if val_num == target_num:
                    # 等于就不写入这一行了(算删除)
                    count += 1
                    continue
            if operator == '>':
                if val_num > target_num:
                    count += 1
                    continue
            if operator == '<':
                if val_num < target_num:
                    count += 1
                    continue
                # 不等于就写入
            rewrite_lines += line

    # w 清空再写入
    with open(f"{table_name}.txt", "w", encoding="utf-8") as f:
        f.write(rewrite_lines)

    print(f"成功删除表 {table_name} 中 {count} 条数据")


def main():
    load_dict()

    while (1):
        sql: str = input("> ")
        if not sql:
            continue
        if sql.lower() == "exit":
            break
        if sql.lower() == "clear":
            print("\033[H\033[2J", end="")
            continue

        sql_upper = sql.upper()
        if (sql_upper.startswith("CREATE TABLE")):
            create_table(sql)
        elif sql_upper.startswith("INSERT INTO"):
            insert_into(sql)
        elif sql_upper.startswith("SELECT"):
            select_from(sql)
        elif sql_upper.startswith("DELETE FROM"):
            delete_from(sql)
        elif sql_upper.startswith("DROP TABLE"):
            drop_table(sql)
        elif sql_upper == "SHOW TABLES":
            if not data_dict:
                print("数据库为空")
            else:
                for t in data_dict.keys():
                    print(f" - {t} ")
        else:
            print("语法错误")

    '''
    create_table("CREATE TABLE student (id int, name str);")
    insert_into("INSERT INTO student VALUES (1, '张三')")
    insert_into("INSERT INTO student VALUES (2, '李四')")
    select_from("SELECT * FROM student")
    delete_from("DELETE FROM student WHERE id = 1")
    select_from("SELECT * FROM student")
    # drop_table("DROP TABLE student")
    # select_from("SELECT * FROM student")
    # print(data_dict)
    '''

if __name__ == "__main__":
    main()