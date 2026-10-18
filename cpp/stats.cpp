#include <iostream>
#include <ctime>
#include <cstdlib>

using namespace std;

// Шанс успеха (например, 10%)
const float CUSTOM_SUCCESS_RATE = 0.0035f; // 0.35%

int main() {
    // Инициализируем RNG один раз
    srand((unsigned)time(nullptr));

    const int TRIALS = 10000; // число независимых испытаний
    long long totalAttempts = 0; // суммарное число попыток (включая успешные)
    long long trialsWithFailStreakOver25 = 0; // сколько испытаний имели >25 неудач подряд

    const int SCALE = 100000; // масштаб для rand()
    int successThreshold = (int)(CUSTOM_SUCCESS_RATE * SCALE);

    for (int t = 0; t < TRIALS; ++t) {
        int attempts = 0;
        // повторяем попытки внутри одного испытания, пока не будет успеха
        while (true) {
            ++attempts;
            int randVal = rand() % SCALE; // 0..SCALE-1
            if (randVal < successThreshold) {
                // успех — выходим из цикла испытания
                break;
            }
            // иначе — неудача, продолжаем
        }

        totalAttempts += attempts;
        int failuresBeforeSuccess = attempts - 1;
        if (failuresBeforeSuccess > 25) {
            ++trialsWithFailStreakOver25;
        }
    }

    cout << "Trials: " << TRIALS << endl;
    cout << "Среднее количество попыток до успеха: "
         << (double)totalAttempts / (double)TRIALS << endl;
    cout << "Испытаний, где было более 25 подряд неудач перед успехом: "
         << trialsWithFailStreakOver25 << endl;

    return 0;
}

