from sklearn.preprocessing import MinMaxScaler

def normalizar(coluna):
    scaler = MinMaxScaler()
    return scaler.fit_transform(coluna.to_frame()).flatten()