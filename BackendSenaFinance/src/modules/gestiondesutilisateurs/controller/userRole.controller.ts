import { Request, Response } from "express";
import { myDataSource } from "../../../configs/data-source";
import { generateServerErrorCode, success, validateMessage } from "../../../configs/response";
import { ValidationError, validate } from "class-validator";
import { UserRole } from "../entity/UserRole.entity";

    
    export const createUserRole = async (req: Request, res: Response) => {
        if (!req.body.roles && req.body.roles.length < 0) {
            return generateServerErrorCode(res,400,"Aucune liste de roles","Aucune liste de roles")
        }
        
        await myDataSource.manager.transaction(async (transactionalEntityManager) => {

            //Le front doit envoyer ce modele
            /**
             * objet : {
             * roles:number[],
             * userId:number    
             * }
             */
            const roles = req.body.roles
            const userId = req.body.userId;
            console.log('roles',roles)
            console.log('userId',userId)
            
            let userRoles = [];
            if(roles && userId) {
                for (let index = 0; index < roles.length; index++) {
                    const userRole = new UserRole()
                    userRole.userId = userId;
                    userRole.roleId = roles[index];
                    userRole.dateAffectation = new Date();
                    userRoles.push(userRole);
                }
            await transactionalEntityManager.save(userRoles);
            console.log('userRoles',userRoles)
            }
        }).then(userRoles=>{
            const message = `Le rôle a été mis à jour avec succès`
            return success(res,200, userRoles,message);
        }).catch(error => {
            if(error instanceof ValidationError) {
                return generateServerErrorCode(res,400,error,'Ce role existe déjà')
            }
            if(error.code == "ER_DUP_ENTRY") {
                return generateServerErrorCode(res,400,error,'Ce role existe déjà')
            }
            const message = `Le rôle n'a pas pu être ajouté. Réessayez dans quelques instants.`
            return generateServerErrorCode(res,500,error,message)
        })
    }


   /* export const getUserRole = async (req: Request, res: Response) => {
        await myDataSource.getRepository(UserRole).findOneBy({id: parseInt(req.params.id)})
        .then(role => {
            if(role === null) {
              const message = `Le role demandé n'existe pas. Réessayez avec un autre identifiant.`
              return generateServerErrorCode(res,400,"L'id n'existe pas",message)
            }
            const message = 'Le role a bien été trouvé.'
            return success(res,200, role,message);
        })
        .catch(error => {
            const message = `Le role n'a pas pu être récupéré. Réessayez dans quelques instants.`
            return generateServerErrorCode(res,500,error,message)
        })
    }; */
    

    
    export const deleteUserRole = async (req: Request, res: Response) => {
        //const resultat = await checkRelationsOneToMany('Role', parseInt(req.params.id));
        await myDataSource.getRepository(UserRole).findOneBy({id: parseInt(req.params.id)}).then(userRole => {        
            if(userRole === null) {
            const message = `Le role de l'utilisateur demandé n'existe pas. Réessayez avec un autre identifiant.`
            return generateServerErrorCode(res,400,"L'id n'existe pas",message);
            }
            myDataSource.getRepository(UserRole).softRemove(userRole)
            .then(_ => {
                const message = `Le rôle de l'utilisateur avec l'identifiant n°${userRole.id} a bien été supprimé.`;
                return success(res,200, userRole,message);
            })
        })
        .catch(error => {
            const message = `Le rôle n'a pas pu être supprimé. Réessayez dans quelques instants.`
            return generateServerErrorCode(res,500,error,message)
        })
    }