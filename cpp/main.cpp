#include <iostream>
#include <ctime>
#include <cstdlib>
#include <unistd.h>

using namespace std;

// Шанс успеха, заданный вручную (например, 10%)
const float CUSTOM_SUCCESS_RATE =  0.0035f; // 0.35%

bool TryUpgrade() {
    srand((unsigned)time(NULL));

    int itemLevel = 7;

    // Просто используем ручной шанс
    float totalRate = CUSTOM_SUCCESS_RATE;

    int randVal = rand() % 100000;
    int successThreshold = (int)(totalRate * 100000);
   
    //cout << "Попытка заточки предмета +" << itemLevel << endl;
    //cout << "Суммарный шанс успеха: " << (totalRate * 100.0f) << "%\n";
    //cout << "Rand Value: " << randVal << endl;
    //cout << "Success treshold: " << successThreshold << endl;
    if (randVal <= successThreshold) {
        cout << "✅ Успешная заточка!" << endl;
        return true;
    }

    //cout << "❌ Неудача!" << endl;

    // Шанс сгорания таликов
    bool bTalikBreak = false;
    if ((rand() % 1000) < 100) { // 10%
        bTalikBreak = true;
        //cout << "🔥 Талики сгорели!" << endl;
    }

    // Шанс поломки предмета
    bool bItemBreak = false;
    if ((rand() % 1000) < 100) {
        bItemBreak = true;
        //cout << "💥 Предмет сломан!" << endl;
    }
    return false;
}

int main() {
    // Запускаем 1 или более раз для тестов
    int j = 0;
    for(int i = 0; i < 1000; i++) {
    	j = i;
    	if (TryUpgrade()) {
    		break;
    	}
    	
    	sleep(1);
    	cout << j << endl;
    }
    
    cout << "Amount of attempts: " << j << endl; 
    
    return 0;
}

