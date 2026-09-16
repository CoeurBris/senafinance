import { Request, Response } from "express";
import { myDataSource } from "../../../configs/data-source";
import { generateServerErrorCode, success, validateMessage } from "../../../configs/response";
import { ValidationError, validate } from "class-validator";
import { UserPointVente } from "../entity/UserPointVente.entity";

    
    export const createUserPointVente = async (req: Request, res: Response) => {
        if (!req.body.pointventes || req.body.pointventes.length == 0) {
            return generateServerErrorCode(res,400,"Aucune liste de pointventes","Aucune liste de pointventes")
        }

        const pointventes = req.body.pointventes
            const userId = req.params.id;
            console.log('pointventes',pointventes)
            console.log('userId',userId)
            
            let userPointVentes = [];
            if(pointventes && userId) {
                for (let index = 0; index < pointventes.length; index++) {
                    userPointVentes.push({ user : userId, pointvente : pointventes[index]});
                }
             }
            console.log('userPointVentes je suis la',userPointVentes)
        
        await myDataSource.getRepository(UserPointVente).save(userPointVentes)
        .then(data=>{
            const message = `Le point de vente a été mis à jour avec succès`
            return success(res,200, data,message);
        }).catch(error => {
            if(error instanceof ValidationError) {
                return generateServerErrorCode(res,400,error,'Ce point de vente existe déjà')
            }
            if(error.code == "ER_DUP_ENTRY") {
                return generateServerErrorCode(res,400,error,'Ce point de vente existe déjà')
            }
            const message = `Le point de vente n'a pas pu être ajouté. Réessayez dans quelques instants.`
            return generateServerErrorCode(res,500,error,message)
        })
    }


 

    
    export const deleteUserPointVente = async (req: Request, res: Response) => {
        //const resultat = await checkRelationsOneToMany('Role', parseInt(req.params.id));
        await myDataSource.getRepository(UserPointVente).findOneBy({id: parseInt(req.params.id)}).then(userPointVente => {        
            if(userPointVente === null) {
            const message = `Le pointvente de l'utilisateur demandé n'existe pas. Réessayez avec un autre identifiant.`
            return generateServerErrorCode(res,400,"L'id n'existe pas",message);
            }
            myDataSource.getRepository(UserPointVente).softRemove(userPointVente)
            .then(_ => {
                const message = `Le rôle de l'utilisateur avec l'identifiant n°${userPointVente.id} a bien été supprimé.`;
                return success(res,200, userPointVente,message);
            })
        })
        .catch(error => {
            const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`
            return generateServerErrorCode(res,500,error,message)
        })
    }