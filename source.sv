#include <iostream>
#include <vector>
#include <string>
#include <sstream> 
#include <bitset> 
#include <iomanip>
#include <fstream>
using namespace std;


vector<vector<string>>Sbox = { {"63","7c","77","7b","f2","6b","6f","c5","30","01","67","2b","fe","d7","ab","76"},
							   {"ca","82","c9","7d","fa","59","47","f0","ad","d4","a2","af","9c","a4","72","c0"},
							   {"b7","fd","93","26","36","3f","f7","cc","34","a5","e5","f1","71","d8","31","15"},
							   {"04","c7","23","c3","18","96","05","9a","07","12","80","e2","eb","27","b2","75"},
							   {"09","83","2c","1a","1b","6e","5a","a0","52","3b","d6","b3","29","e3","2f","84"},
							   {"53","d1","00","ed","20","fc","b1","5b","6a","cb","be","39","4a","4c","58","cf"},
							   {"d0","ef","aa","fb","43","4d","33","85","45","f9","02","7f","50","3c","9f","a8"},
							   {"51","a3","40","8f","92","9d","38","f5","bc","b6","da","21","10","ff","f3","d2"},
							   {"cd","0c","13","ec","5f","97","44","17","c4","a7","7e","3d","64","5d","19","73"},
							   {"60","81","4f","dc","22","2a","90","88","46","ee","b8","14","de","5e","0b","db"},
							   {"e0","32","3a","0a","49","06","24","5c","c2","d3","ac","62","91","95","e4","79"},
							   {"e7","c8","37","6d","8d","d5","4e","a9","6c","56","f4","ea","65","7a","ae","08"},
							   {"ba","78","25","2e","1c","a6","b4","c6","e8","dd","74","1f","4b","bd","8b","8a"},
							   {"70","3e","b5","66","48","03","f6","0e","61","35","57","b9","86","c1","1d","9e"},
							   {"e1","f8","98","11","69","d9","8e","94","9b","1e","87","e9","ce","55","28","df"},
							   {"8c","a1","89","0d","bf","e6","42","68","41","99","2d","0f","b0","54","bb","16"} };

vector<string>G_BOX = { "01","02","04","08","10","20","40","80","1B","36" };

vector<vector<string>> sub(vector<vector<string>>matrix)
{
	int x, y;
	for (int i = 0; i < matrix.size(); i++)
	{
		for (int j = 0; j < matrix[i].size(); j++)
		{
			x = stoi(matrix[i][j].substr(0, 1), 0, 16);
			y = stoi(matrix[i][j].substr(1, 1), 0, 16);
			matrix[i][j] = Sbox[x][y];
		}
	}
	return matrix;
}
vector<vector<string>> shift(vector<vector<string>>matrix)
{
	sub(matrix);

	string temp1, temp2, temp3;

	temp1 = matrix[1][0];
	matrix[1][0] = matrix[1][1];
	matrix[1][1] = matrix[1][2];
	matrix[1][2] = matrix[1][3];
	matrix[1][3] = temp1;


	temp1 = matrix[2][0];
	temp2 = matrix[2][1];
	matrix[2][0] = matrix[2][2];
	matrix[2][1] = matrix[2][3];
	matrix[2][2] = temp1;
	matrix[2][3] = temp2;

	temp1 = matrix[3][0];
	temp2 = matrix[3][1];
	temp3 = matrix[3][2];
	matrix[3][0] = matrix[3][3];
	matrix[3][1] = temp1;
	matrix[3][2] = temp2;
	matrix[3][3] = temp3;

	return matrix;
}

int mul(int a, int b)
{
	string m = "11B";
	unsigned long long  MValue;

	bitset<9> A(a);
	bitset<9> B(b);

	stringstream ostm(m);
	ostm >> hex >> MValue;
	bitset<9> M(MValue);

	bitset<9> mul = 0;


	for (int i = 0; i < 8; i++)
	{
		if (B[i] == 1)
		{
			mul ^= A;
		}
		A <<= 1;
		if (A[8] == 1)
		{
			A ^= M;
		}
	}

	return (int)(mul.to_ulong());
}

int add(int a, int b)
{
	string m = "11B";
	unsigned long long  MValue;

	bitset<9> A(a);
	bitset<9> B(b);

	stringstream ostm(m);
	ostm >> hex >> MValue;
	bitset<9> M(MValue);

	bitset<9> out;

	out = A ^ B;
	if (out[8] == 1)
	{
		out ^= M;
	}

	return (int)(out.to_ulong());
}

vector<vector<string>> mix(vector<vector<string>>matrix)
{
	vector<vector<string>>res(4, vector<string>(4));

	int m0, m1, m2, m3;
	for (int j = 0; j < 4; j++)
	{
		stringstream s0, s1, s2, s3;
		m0 = stoi(matrix[0][j], 0, 16);
		m1 = stoi(matrix[1][j], 0, 16);
		m2 = stoi(matrix[2][j], 0, 16);
		m3 = stoi(matrix[3][j], 0, 16);
		s0 << setw(2) << setfill('0') << hex << uppercase << add(add(mul(2, m0), mul(3, m1)), add(m2, m3));
		s0 >> res[0][j];
		s1 << setw(2) << setfill('0') << hex << uppercase << add(add(m0, mul(2, m1)), add(mul(3, m2), m3));
		s1 >> res[1][j];
		s2 << setw(2) << setfill('0') << hex << uppercase << add(add(m0, m1), add(mul(2, m2), mul(3, m3)));
		s2 >> res[2][j];
		s3 << setw(2) << setfill('0') << hex << uppercase << add(add(mul(3, m0), m1), add(m2, mul(2, m3)));
		s3 >> res[3][j];
	}
	return res;
}

string G_FUN(string word, int round)
{
	unsigned long long textValue, keyValue;
	stringstream s0, s1;
	vector<vector<string>>matrix(1, vector<string>(4));
	int x, y;

	matrix[0][0] = word.substr(2, 2);
	matrix[0][1] = word.substr(4, 2);
	matrix[0][2] = word.substr(6, 2);
	matrix[0][3] = word.substr(0, 2);

	matrix = sub(matrix);



	int m0 = stoi(matrix[0][0], 0, 16);
	int m1 = stoi(G_BOX[round], 0, 16);

	s0 << setw(2) << setfill('0') << hex << uppercase << add(m0, m1);
	s0 >> matrix[0][0];

	return (matrix[0][0] + matrix[0][1] + matrix[0][2] + matrix[0][3]);

}

vector<vector<string>> KEY_GEN(vector<vector<string>>matrix, int Round)
{
	stringstream s0, s1, s2, s3, ss, f0, f1, f2, f3;
	string       w0, w1, w2, w3;
	unsigned int word3, word0, word1, word2, word;

	string wordG = matrix[0][3] + matrix[1][3] + matrix[2][3] + matrix[3][3];

	string x0 = (matrix[0][0] + matrix[1][0] + matrix[2][0] + matrix[3][0]);
	string x1 = (matrix[0][1] + matrix[1][1] + matrix[2][1] + matrix[3][1]);
	string x2 = (matrix[0][2] + matrix[1][2] + matrix[2][2] + matrix[3][2]);


	s0 << std::hex << x0;
	s0 >> word0;

	s1 << std::hex << x1;
	s1 >> word1;

	s2 << std::hex << x2;
	s2 >> word2;

	s3 << std::hex << wordG;
	s3 >> word;


	ss << std::hex << G_FUN(wordG, Round);
	ss >> word3;

	unsigned int w4 = word3 ^ word0;
	unsigned int w5 = w4 ^ word1;
	unsigned int w6 = w5 ^ word2;
	unsigned int w7 = w6 ^ word;

	f0 << setw(8) << setfill('0') << hex << uppercase << w4;
	f0 >> w0;
	f1 << setw(8) << setfill('0') << hex << uppercase << w5;
	f1 >> w1;
	f2 << setw(8) << setfill('0') << hex << uppercase << w6;
	f2 >> w2;
	f3 << setw(8) << setfill('0') << hex << uppercase << w7;
	f3 >> w3;

	for (int i = 0, index = 0; i < 4; i++, index = index + 2)
	{
		matrix[i][0] = w0.substr(index, 2);
		matrix[i][1] = w1.substr(index, 2);
		matrix[i][2] = w2.substr(index, 2);
		matrix[i][3] = w3.substr(index, 2);
	}

	return matrix;
}

vector<vector<string>> addRound(vector<vector<string>>matrix, vector<vector<string>> key)
{
	unsigned long long textValue, keyValue;
	int m0, m1;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			stringstream s0;
			m0 = stoi(matrix[i][j], 0, 16);
			m1 = stoi(key[i][j], 0, 16);
			s0 << setw(2) << setfill('0') << hex << add(m0, m1);
			s0 >> matrix[i][j];
		}

	}

	return matrix;
}


extern "C"  char* decrypt1(char* ke1, char* input1)
{
	vector<vector<string>>matrix(4, vector<string>(4));
	vector<vector<string>>key(4, vector<string>(4));

	
   int a_size = sizeof(input1) / sizeof(char); 
    int b_size = sizeof(ke1) / sizeof(char); 
  
    string ke = convertToString(ke1, a_size); 
    string input = convertToString(input1, b_size); 
	int num;
	//cin >> ke >> input >> num;
	//ofstream myfile("example.txt");
	//ke = argv[1];
	//input = argv[2];
	int index = 0;
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			matrix[j][i] = input.substr(index, 2);
			key[j][i] = ke.substr(index, 2);
			index += 2;
		}
	}

	

		matrix = addRound(matrix, key);

		for (int i = 0; i < 10; i++)
		{

			matrix = sub(matrix);
			matrix = shift(matrix);

			if (i != 9)
				matrix = mix(matrix);

			key = KEY_GEN(key, i);
			matrix = addRound(matrix, key);

		}
		index = 0;
		for (int ji = 0; ji < 4; ji++)
		{
			for (int kj = 0; kj < 4; kj++)
			{
				key[kj][ji] = ke.substr(index, 2);
				index += 2;
			}
		}

	
  string str = "";
	for (int i = 0; i < 4; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			str  +=  ((char)matrix[j][i]);
		}
	}


	return  (char*)str.c_str();;

}