from load_data import load_all_raw_data
from load_data import load_all_dtype_data
from load_data import fillna_num
from load_data import no_values_object
from load_data import see_outliers
from load_data import outliers_removal
from load_data import clean_data

def main():
    # files = load_all_raw_data()
    files = load_all_dtype_data()
    # fillna_num(files)
    # no_values_object(files)
    # print(see_outliers(files))
    # print(outliers_removal(files))
    # print(see_outliers(files))
    #print(files)
    print(clean_data())
    print("deu boa")

main()

if __name__ == "__main__":
    main